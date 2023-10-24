#! /usr/bin/env python
'''User logout'''

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


def check_inputs(req_body):
    '''Validate inputs'''
    return assert_valid_schema(req_body, constants.USER_LOGOUT_JSON_SCHEMA)


def user_logout(email, access_token, conf_values):
    '''Perform the user logout'''
    try:
        cup_client = boto3.client('cognito-idp', constants.REGION)
        response = cup_client.global_sign_out(AccessToken=access_token)
        return 'OK'
    except Exception as error:
        print('User: %s has trouble to logout' %email)
        print('Error - {0}'.format(error))
        return 'KO'


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
        user_logout_session = user_logout(req_body['email'], req_body['access_token'], conf_values)
        if user_logout_session == 'KO':
            return {
                'statusCode': 401,
                'body': json.dumps({'error_message': 'Logout error'}),
                'headers': {
                    'Content-Type' : 'application/json',
                    'Access-Control-Allow-Origin' : '*',
                    'Allow' : 'POST, OPTIONS',
                    'Access-Control-Allow-Methods' : 'POST, OPTIONS',
                    'Access-Control-Allow-Headers' : '*'
                },
                'isBase64Encoded': False,
            }

        return {
            'statusCode': 200,
            'body': json.dumps({'user_status': 'logout'}),
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
