#! /usr/bin/env python
'''Delete an existing user'''

import os
import json
import collections
from os.path import join, dirname
import boto3
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


def is_user_authorized(event):
    '''Check if the user is authorized to perform actions on the given endpoint'''
    user_id = event['requestContext']['authorizer']['claims']['sub']
    event_user_id = event['pathParameters']['user_id']
    if user_id == event_user_id:
        print('User: '+user_email+', is allowed to access: '+event['path'])
        return True
    else:
        print('User: '+user_id+', is not allowed to access: '+event['path'])
        return False


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


def delete_user(email, conf_values):
    '''Delete an existing user'''
    try:
        cup_client = boto3.client('cognito-idp', conf_values['REGION'])
        cup_client.admin_delete_user(
            UserPoolId=conf_values['COGNITO_USER_POOL_ID'],
            Username=email
        )
        return True
    except Exception as error:
        return False
        print('Error: {}'.format(error))


def build_api_response(email, user_id):
    '''Build the API response'''
    response_body = collections.OrderedDict()
    response_body['email'] = email
    response_body['user_id'] = user_id
    response_body['status'] = 'USER_DELETED'

    return response_body


def init_env_vars():
    '''Get all environment variables'''
    conf_values = {}
    conf_values['REGION'] = os.getenv(constants.REGION)
    conf_values['COGNITO_USER_POOL_ID'] = os.getenv(constants.COGNITO_USER_POOL_ID)
    return conf_values


def lambda_handler(event, context):
    '''Lambda entrypoint'''
    if is_invoked_by_lambda_warmer(event):
        return {
            'statusCode': 200,
            'body': json.dumps({'message':'Lambda warmer check OK!'}),
        }
    try:
        LOGGER.info(event)
        if not is_user_authorized(event):
            return {
                'statusCode': 401,
                'body': json.dumps({'error_message': 'Not authorized'}),
                'headers': {
                    'Content-Type' : 'application/json',
                    'Access-Control-Allow-Origin' : '*',
                    'Allow' : 'DELETE, OPTIONS',
                    'Access-Control-Allow-Methods' : 'DELETE, OPTIONS',
                    'Access-Control-Allow-Headers' : '*'
                },
                'isBase64Encoded': False,
            }
        user_id = event['pathParameters']['user_id']
        conf_values = init_env_vars()
        email = assert_user_exist(user_id, conf_values)
        if user_id is None:
            return {
                'statusCode': 401,
                'body': json.dumps({'error_message': 'Not authorized'}),
                'headers': {
                    'Content-Type' : 'application/json',
                    'Access-Control-Allow-Origin' : '*',
                    'Allow' : 'DELETE, OPTIONS',
                    'Access-Control-Allow-Methods' : 'DELETE, OPTIONS',
                    'Access-Control-Allow-Headers' : '*'
                },
                'isBase64Encoded': False,
            }
        response_delete_user = delete_user(
            email,
            conf_values
        )
        if not response_delete_user:
            return {
                'statusCode': 401,
                'body': json.dumps({'error_message': 'Cannot delete the user, contact the support'}),
                'headers': {
                    'Content-Type' : 'application/json',
                    'Access-Control-Allow-Origin' : '*',
                    'Allow' : 'DELETE, OPTIONS',
                    'Access-Control-Allow-Methods' : 'DELETE, OPTIONS',
                    'Access-Control-Allow-Headers' : '*'
                },
                'isBase64Encoded': False,
            }

        response_body = build_api_response(
            email,
            user_id
        )
        return {
            'statusCode': 200,
            'body': json.dumps(response_body),
            'headers': {
                'Content-Type' : 'application/json',
                'Access-Control-Allow-Origin' : '*',
                'Allow' : 'DELETE, OPTIONS',
                'Access-Control-Allow-Methods' : 'DELETE, OPTIONS',
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
                'Allow' : 'DELETE, OPTIONS',
                'Access-Control-Allow-Methods' : 'DELETE, OPTIONS',
                'Access-Control-Allow-Headers' : '*'
            },
            'isBase64Encoded': False,
        }
