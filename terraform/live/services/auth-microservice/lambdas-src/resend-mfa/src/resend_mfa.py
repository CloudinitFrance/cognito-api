#! /usr/bin/env python
'''Resend User MFA'''

import os
import json
import collections
from os.path import join, dirname
from email.mime.application import MIMEApplication
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from jsonschema import validate
import jsonschema
import boto3
import botocore
from boto3.s3.transfer import S3Transfer
import constants
import log


LOGGER = log.setup_logging()


def is_invoked_by_lambda_warmer(event):
    '''If the event is a scheduled warmer just say ok'''
    # We can be more precise by using: {context.invoked_function_name}-warmer
    # as a event name
    if 'detail-type' in event and event['detail-type'] == 'Scheduled Event':
        if event['resources'][0].endswith('warmer'):
            return True
        else:
            return False


def _load_json_schema(filename):
    ''' Loads the given schema file '''

    relative_path = join(constants.SCHEMAS_FOLDER, filename)
    absolute_path = join(dirname(__file__), relative_path)

    with open(absolute_path) as schema_file:
        return json.loads(schema_file.read())


def assert_valid_schema(data, schema_file):
    ''' Checks whether the given data matches the schema '''

    schema = _load_json_schema(schema_file)
    try:
        validate(data, schema)
        return True, None
    except jsonschema.exceptions.ValidationError as error:
        return False, error.message


def assert_user_exist(email, conf_values):
    '''Check if the given user exist'''
    try:
        client = boto3.client('cognito-idp')
        response = client.admin_get_user(
            UserPoolId=conf_values['COGNITO_USER_POOL_ID'],
            Username=email
        )
        return response['Username']
    except botocore.exceptions.ClientError as error:
        if error.response['Error']['Code'] == 'UserNotFoundException':
            LOGGER.info('User does not exist!')
            return None
        else:
            LOGGER.error(error)
            return None


def check_inputs(req_body):
    '''Validate inputs'''
    return assert_valid_schema(req_body, constants.RESEND_MFA_JSON_SCHEMA)


def create_qr_message(email, qr_code_secret_url, from_email):
    '''Create user QR Code'''
    message = MIMEMultipart()
    message['subject'] = 'Your API MFA QR Code'
    message['From'] = from_email
    message['To'] = email
    with open('templates/html_mail.html') as template_file:
        html_template = template_file.read()
    html_msg = html_template.replace('QRCODE_LINK', qr_code_secret_url.decode('utf-8'))
    body = MIMEText(html_msg, 'html')
    message.attach(body)

    return message


def send_qr_code(email, qr_code_secret_url, from_email):
    '''Send an email to the user containing his QR Code Link'''
    message = create_qr_message(email, qr_code_secret_url, from_email)
    ses_client = boto3.client('ses')
    ses_client.send_raw_email(
        Source=message['FROM'],
        Destinations=[email],
        RawMessage={'Data': message.as_string()}
    )

def gen_url(s3_client, s3_bucket, s3_file_key):
    '''Generate the URL to get s3_file_key from s3_bucket'''
    url = s3_client.generate_presigned_url(
        ClientMethod='get_object',
        ExpiresIn=600,
        Params={
            'Bucket': s3_bucket,
            'Key': s3_file_key
        }
    )

    return url.encode('utf-8')


def reset_user_mfa(user_id, email, conf_values):
    '''Reset the user MFA'''
    # Upload to s3 and generate presigned URL
    s3_client = boto3.client('s3', conf_values['REGION'])
    qr_code_secret_url = gen_url(
        s3_client,
        conf_values['S3_BUCKET_MFA_BUCKET'],
        conf_values['USERS_MFA_FOLDER'] + '/' + user_id + '.png'
    )
    send_qr_code(email, qr_code_secret_url, conf_values['FROM_EMAIL'])

    return qr_code_secret_url


def build_api_response(email, user_id, qr_code_secret_url):
    '''Build the API response'''
    response_body = collections.OrderedDict()
    response_body['email'] = email
    response_body['user_id'] = user_id
    response_body['qr_code_secret_url'] = qr_code_secret_url.decode('utf-8')

    return response_body


def init_env_vars():
    '''Get all environment variables'''
    conf_values = {}
    conf_values['REGION'] = os.getenv(constants.REGION)
    conf_values['S3_BUCKET_MFA_BUCKET'] = os.getenv(constants.S3_BUCKET_MFA_BUCKET)
    conf_values['USERS_MFA_FOLDER'] = os.getenv(constants.USERS_MFA_FOLDER)
    conf_values['FROM_EMAIL'] = os.getenv(constants.FROM_EMAIL)
    conf_values['COGNITO_USER_POOL_ID'] = os.getenv(constants.COGNITO_USER_POOL_ID)
    return conf_values


def lambda_handler(event, _):
    '''Lambda entrypoint'''
    if is_invoked_by_lambda_warmer(event):
        return {
            'statusCode': 200,
            'body': json.dumps({'message':'Lambda warmer check OK!'}),
        }
    try:
        req_body = json.loads(event['body'])
        LOGGER.info(req_body)
        is_payload_data_valid, error_msg = check_inputs(req_body)
        if not is_payload_data_valid:
            return {
                'statusCode': 400,
                'body': json.dumps({'message':error_msg}),
                'headers': {
                    'Content-Type' : 'application/json',
                    'Access-Control-Allow-Origin' : '*',
                    'Allow' : 'POST, OPTIONS',
                    'Access-Control-Allow-Methods' : 'POST, OPTIONS',
                    'Access-Control-Allow-Headers' : '*'
                }
            }
        conf_values = init_env_vars()
        user_id = assert_user_exist(req_body['email'].lower(), conf_values)
        if user_id is None:
            return {
                'statusCode': 401,
                'body': json.dumps({'error_message': 'Not authorized'}),
                'headers': {
                    'Content-Type' : 'application/json',
                    'Access-Control-Allow-Origin' : '*',
                    'Allow' : 'POST, OPTIONS',
                    'Access-Control-Allow-Methods' : 'POST, OPTIONS',
                    'Access-Control-Allow-Headers' : '*'
                },
                'isBase64Encoded': False,
            }
        qr_code_secret_url = reset_user_mfa(
            user_id,
            req_body['email'],
            conf_values
        )
        response_body = build_api_response(
            req_body['email'].lower(),
            user_id,
            qr_code_secret_url
        )
        return {
            'statusCode': 200,
            'body': json.dumps(response_body),
            'headers': {
                'Content-Type' : 'application/json',
                'Access-Control-Allow-Origin' : '*',
                'Allow' : 'POST, OPTIONS',
                'Access-Control-Allow-Methods' : 'POST, OPTIONS',
                'Access-Control-Allow-Headers' : '*'
            },
            'isBase64Encoded': False,
        }
    except Exception as error:
        err_msg = {'error_message': '{}'.format(error)}
        LOGGER.error(err_msg)
        return {
            'statusCode': 400,
            'body': json.dumps(err_msg),
            'headers': {
                'Content-Type' : 'application/json',
                'Access-Control-Allow-Origin' : '*',
                'Allow' : 'POST, OPTIONS',
                'Access-Control-Allow-Methods' : 'POST, OPTIONS',
                'Access-Control-Allow-Headers' : '*'
            },
            'isBase64Encoded': False,
        }
