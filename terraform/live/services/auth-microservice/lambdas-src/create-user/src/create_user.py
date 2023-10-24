#! /usr/bin/env python
'''Create a new Cognito User'''

import os
import uuid
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
    '''if the event is a scheduled warmer just say ok'''
    # we can be more precise by using: {context.invoked_function_name}-warmer
    # as a event name
    if 'detail-type' in event and event['detail-type'] == 'scheduled event':
        if event['resources'][0].endswith('warmer'):
            return true
        else:
            return false


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
        return True
    except botocore.exceptions.ClientError as error:
        if error.response['Error']['Code'] == 'UserNotFoundException':
            LOGGER.info('User does not exist!')
            return False
        else:
            LOGGER.error(error)
            return True


def check_inputs(req_body):
    '''Validate inputs'''
    return assert_valid_schema(req_body, constants.NEW_USER_JSON_SCHEMA)


def create_user(req_body, conf_values):
    '''Create cognito user'''
    try:
        cup_client = boto3.client('cognito-idp', conf_values['REGION'])
        response = cup_client.admin_create_user(
            UserPoolId=conf_values['COGNITO_USER_POOL_ID'],
            Username=req_body['email'].lower(),
            UserAttributes=[
                {
                    'Name': 'name',
                    'Value': req_body['full_name']
                },
                {
                    'Name': 'email',
                    'Value': req_body['email'].lower()
                },
                {
                    'Name': 'phone_number',
                    'Value': req_body['mobile_phone_number']
                },
                {
                    'Name': 'email_verified',
                    'Value': 'true'
                }
            ],
            DesiredDeliveryMediums=['EMAIL']
        )
        user_attributes = response['User']['Attributes']
        for attr in user_attributes:
            if attr['Name'] == 'sub':
                user_sub = attr['Value']
        if user_sub is None:
            print('ERROR: user_sub is NONE!')
            raise Exception('Internal server error')
        return user_sub
    except Exception as error:
        LOGGER.error(error)
        raise Exception('Internal server error')


def build_api_response(email, user_id):
    '''Build the API response'''
    response_body = collections.OrderedDict()
    response_body['email'] = email
    response_body['user_id'] = user_id
    response_body['status'] = 'CREATED'

    return response_body


def init_env_vars():
    '''Get all environment variables'''
    conf_values = {}
    conf_values['REGION'] = os.getenv(constants.REGION)
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
        user_exist = assert_user_exist(req_body['email'].lower(), conf_values)
        if user_exist:
            return {
                'statusCode': 401,
                'body': json.dumps({'error_message': 'Cannot create the user, contact the support'}),
                'headers': {
                    'Content-Type' : 'application/json',
                    'Access-Control-Allow-Origin' : '*',
                    'Allow' : 'POST, OPTIONS',
                    'Access-Control-Allow-Methods' : 'POST, OPTIONS',
                    'Access-Control-Allow-Headers' : '*'
                },
                'isBase64Encoded': False,
            }
        user_id = create_user(req_body, conf_values)
        response_body = build_api_response(
            req_body['email'].lower(),
            user_id
        )
        return {
            'statusCode': 201,
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
