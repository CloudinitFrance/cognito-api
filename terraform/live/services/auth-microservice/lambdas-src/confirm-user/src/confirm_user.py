#! /usr/bin/env python
'''Confirm a new Cognito User'''

import os
import json
import collections
from os.path import join, dirname
from jsonschema import validate
import jsonschema
import boto3
from boto3.s3.transfer import S3Transfer
import botocore
import pyotp
import qrcode
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
    return assert_valid_schema(req_body, constants.CONFIRM_USER_JSON_SCHEMA)


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


def upload_to_s3(s3_client, bucket_name, local_file_path, remote_file_path):
    '''Upload the given file to S3 bucket with encryption enabled'''
    transfer = S3Transfer(s3_client)
    transfer.upload_file(local_file_path,
        bucket_name,
        remote_file_path,
        extra_args={'ServerSideEncryption': 'AES256'}
    )


def confirm_new_user(user_id, email, temporary_password, new_password, conf_values):
    '''Confirm the new user'''
    cup_client = boto3.client('cognito-idp', conf_values['REGION'])

    response_init_auth = cup_client.admin_initiate_auth(
        UserPoolId=conf_values['COGNITO_USER_POOL_ID'],
        AuthFlow='ADMIN_NO_SRP_AUTH',
        AuthParameters={
            'USERNAME': email,
            'PASSWORD': temporary_password
        },

        ClientId=conf_values['COGNITO_APP_CLIENT_ID']
    )

    response_challenge = cup_client.admin_respond_to_auth_challenge(
        UserPoolId=conf_values['COGNITO_USER_POOL_ID'],
        ClientId=conf_values['COGNITO_APP_CLIENT_ID'],
        ChallengeName='NEW_PASSWORD_REQUIRED',
        ChallengeResponses={
            'USERNAME': email,
            'NEW_PASSWORD': new_password
        },
        Session=response_init_auth['Session']
    )

    LOGGER.info(response_challenge)

    associate_software_response = \
        cup_client.associate_software_token(Session=response_challenge['Session'])
    LOGGER.info(associate_software_response)
    qr_code_secret = associate_software_response['SecretCode']
    # Verify and confirm
    totp = pyotp.TOTP(qr_code_secret)
    cup_client.verify_software_token(
        Session=associate_software_response['Session'],
        UserCode=totp.now(),
        FriendlyDeviceName=user_id+'-phone'
    )
    cup_client.admin_set_user_mfa_preference(
        SoftwareTokenMfaSettings={
            'Enabled': True,
            'PreferredMfa': True
        },
        Username=email,
        UserPoolId=conf_values['COGNITO_USER_POOL_ID']
    )
    # Generate QrCode Image
    totp = pyotp.TOTP(qr_code_secret)
    qr_code_image = qrcode.make(
        totp.provisioning_uri(email, issuer_name='TheCadors App')
    )
    qr_code_image.save('/tmp/qr_code_img.png')
    # Upload to s3 and generate presigned URL
    s3_client = boto3.client('s3', conf_values['REGION'])
    upload_to_s3(
        s3_client,
        conf_values['S3_BUCKET_MFA_BUCKET'],
        '/tmp/qr_code_img.png',
        'users_mfa/' + user_id + '.png'
    )
    qr_code_secret_url = gen_url(
        s3_client,
        conf_values['S3_BUCKET_MFA_BUCKET'],
        'users_mfa/' + user_id + '.png'
    )
    return qr_code_secret, qr_code_secret_url


def build_api_response(email, user_id, qr_code_secret, qr_code_secret_url):
    '''Build the API response'''
    response_body = collections.OrderedDict()
    response_body['email'] = email
    response_body['user_id'] = user_id
    response_body['qr_code_secret'] = qr_code_secret
    response_body['qr_code_secret_url'] = qr_code_secret_url.decode('utf-8')
    response_body['status'] = 'ACTIVE'

    return response_body


def init_env_vars():
    '''Get all environment variables'''
    conf_values = {}
    conf_values['REGION'] = os.getenv(constants.REGION)
    conf_values['COGNITO_USER_POOL_ID'] = os.getenv(constants.COGNITO_USER_POOL_ID)
    conf_values['COGNITO_APP_CLIENT_ID'] = os.getenv(constants.COGNITO_APP_CLIENT_ID)
    conf_values['S3_BUCKET_MFA_BUCKET'] = os.getenv(constants.S3_BUCKET_MFA_BUCKET)
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
                'body': json.dumps({'error_message': 'Cannot confirm the user, contact the support'}),
                'headers': {
                    'Content-Type' : 'application/json',
                    'Access-Control-Allow-Origin' : '*',
                    'Allow' : 'POST, OPTIONS',
                    'Access-Control-Allow-Methods' : 'POST, OPTIONS',
                    'Access-Control-Allow-Headers' : '*'
                },
                'isBase64Encoded': False,
            }
        qr_code_secret, qr_code_secret_url = confirm_new_user(
            user_id,
            req_body['email'],
            req_body['temporary_password'],
            req_body['new_password'],
            conf_values
        )
        response_body = build_api_response(
            req_body['email'].lower(),
            user_id,
            qr_code_secret,
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
        #TODO: Perform necessary rollback
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
