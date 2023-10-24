#! /usr/bin/env python
'''Confirm User Password'''

import os
import json
import collections
from os.path import join, dirname
from jsonschema import validate
import jsonschema
import boto3
import botocore
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


def is_user_authorized(event, user_id, user_email):
    '''Check if the user is authorized to perform actions on the given endpoint'''
    resource_path_user = event['path'].split('/')[3]
    if user_id == resource_path_user:
        print('User: '+user_email+', is allowed to access: '+event['path'])
        return True
    else:
        print('User: '+user_email+', is not allowed to access: '+event['path'])
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
    return assert_valid_schema(req_body, constants.CONFIRM_PASSWORD_JSON_SCHEMA)


def confirm_password(email, verification_code, new_password, conf_values):
    '''Confirm user password'''
    try:
        LOGGER.info(conf_values['COGNITO_APP_CLIENT_ID'])
        cup_client = boto3.client('cognito-idp', conf_values['REGION'])
        cup_client.confirm_forgot_password(
            ClientId=conf_values['COGNITO_APP_CLIENT_ID'],
            Username=email,
            ConfirmationCode=verification_code,
            Password=new_password
        )
        return True
    except Exception as error:
        print('Error: {}'.format(error))
        return False


def build_api_response(email, user_id):
    '''Build the API response'''
    response_body = collections.OrderedDict()
    response_body['email'] = email
    response_body['user_id'] = user_id
    response_body['status'] = 'NEW_PASSWORD_SET_SUCCESSFULLY'

    return response_body


def init_env_vars():
    '''Get all environment variables'''
    conf_values = {}
    conf_values['REGION'] = os.getenv(constants.REGION)
    conf_values['COGNITO_USER_POOL_ID'] = os.getenv(constants.COGNITO_USER_POOL_ID)
    conf_values['COGNITO_APP_CLIENT_ID'] = os.getenv(constants.COGNITO_APP_CLIENT_ID)
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
                'body': json.dumps({'error_message': 'Cannot confirm password, contact the support'}),
                'headers': {
                    'Content-Type' : 'application/json',
                    'Access-Control-Allow-Origin' : '*',
                    'Allow' : 'POST, OPTIONS',
                    'Access-Control-Allow-Methods' : 'POST, OPTIONS',
                    'Access-Control-Allow-Headers' : '*'
                },
                'isBase64Encoded': False,
            }
        if not is_user_authorized(event, user_id, req_body['email'].lower()):
            return {
                'statusCode': 403,
                'body': json.dumps({'message':'User is not authorized to access this resource'}),
                'headers': {
                    'Content-Type' : 'application/json',
                    'Access-Control-Allow-Origin' : '*',
                    'Allow' : 'POST, OPTIONS',
                    'Access-Control-Allow-Methods' : 'POST, OPTIONS',
                    'Access-Control-Allow-Headers' : '*'
                }
            }
        is_passowrd_confirmed = confirm_password(
            req_body['email'],
            req_body['verification_code'],
            req_body['new_password'],
            conf_values
        )
        if not is_passowrd_confirmed: 
            return {
                'statusCode': 401,
                'body': json.dumps({'error_message': 'Cannot confirm password, contact the support'}),
                'headers': {
                    'Content-Type' : 'application/json',
                    'Access-Control-Allow-Origin' : '*',
                    'Allow' : 'POST, OPTIONS',
                    'Access-Control-Allow-Methods' : 'POST, OPTIONS',
                    'Access-Control-Allow-Headers' : '*'
                },
                'isBase64Encoded': False,
            }
        response_body = build_api_response(
            req_body['email'].lower(),
            user_id
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
        # TODO: Add dynamic error status code support
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
