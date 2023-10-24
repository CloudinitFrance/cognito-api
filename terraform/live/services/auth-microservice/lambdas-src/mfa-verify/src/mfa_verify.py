#! /usr/bin/env python
'''One Time Password Verification'''

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
    return assert_valid_schema(req_body, constants.MFA_VERIFY_JSON_SCHEMA)


def otp_verify(email, verification_session, verification_type, otp_code, conf_values):
    '''Perform the MFA verification step of the user login using the OTP code'''
    try:
        cup_client = boto3.client('cognito-idp', conf_values['REGION'])
        response_challenge = cup_client.admin_respond_to_auth_challenge(
            UserPoolId=conf_values['COGNITO_USER_POOL_ID'],
            ClientId=conf_values['COGNITO_APP_CLIENT_ID'],
            ChallengeName=verification_type,
            ChallengeResponses={
                'USERNAME': email,
                verification_type + '_CODE': otp_code,
            },
            Session=verification_session,
        )
        response_body = collections.OrderedDict()
        response_body['id_token'] = response_challenge['AuthenticationResult'][
            'IdToken'
        ]
        response_body['access_token'] = response_challenge['AuthenticationResult'][
            'AccessToken'
        ]
        response_body['refresh_token'] = response_challenge['AuthenticationResult'][
            'RefreshToken'
        ]
        response_body['expires_in'] = response_challenge['AuthenticationResult'][
            'ExpiresIn'
        ]
        response_body['token_type'] = response_challenge['AuthenticationResult'][
            'TokenType'
        ]
        return response_body
    except Exception as error:
        print('Error - {0}'.format(error))
        return None


def build_api_response(creds):
    '''Build the API response'''
    response_body = collections.OrderedDict()
    response_body['id_token'] = creds['id_token']
    response_body['access_token'] = creds['access_token']
    response_body['refresh_token'] = creds['refresh_token']
    response_body['expires_in'] = creds['expires_in']

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
                'body': json.dumps({'error_message': 'User is not authorized to login'}),
                'headers': {
                    'Content-Type' : 'application/json',
                    'Access-Control-Allow-Origin' : '*',
                    'Allow' : 'POST, OPTIONS',
                    'Access-Control-Allow-Methods' : 'POST, OPTIONS',
                    'Access-Control-Allow-Headers' : '*'
                },
                'isBase64Encoded': False,
            }
        creds = otp_verify(
            req_body['email'].lower(),
            req_body['verification_session'],
            req_body['verification_type'],
            req_body['otp_code'],
            conf_values
        )
        if creds is None:
            return {
                'statusCode': 401,
                'body': json.dumps({'error_message': 'User is not authorized to login'}),
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
            creds
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
