#! /usr/bin/env python
'''Get user infos'''

import os
import json
import collections
import boto3
import jwt
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


def get_userinfo(claims, conf_values):
    '''Get user infos'''
    try:
        cup_client = boto3.client('cognito-idp', conf_values['REGION'])
        response = cup_client.admin_get_user(
            UserPoolId=conf_values['COGNITO_USER_POOL_ID'],
            Username=claims['cognito:username']
        )
        if 'Username' in response:
            user_id = response['Username']
        else:
            user_id = None
        email = None
        name = None
        print(response)
        for attr in response['UserAttributes']:
            if attr['Name'] == 'name':
                name = attr['Value']
            elif attr['Name'] == 'email':
                email = attr['Value']
            else:
                pass
        return user_id, name, email
    except Exception as error:
        raise Exception('Error: {}'.format(error))


def get_claims(jwt_token):
    '''Extract claims from the JWT token'''
    try:
        decode = jwt.decode(
            jwt_token.split(' ')[1],
            algorithms=['RS256'],
            options={"verify_signature": False}
        )
    except Exception as error:
        LOGGER.error(error)
    return decode


def build_api_response(user_id, name, email):
    '''Build the API response'''
    response_body = collections.OrderedDict()
    response_body['user_id'] = user_id
    response_body['email'] = email
    response_body['groups'] = []
    try:
        response_body['given_name'] = name.split(' ', 1)[0]
    except Exception as error:
        print('[ERROR] no given_name for: ' + user_id)
        response_body['given_name'] = None
    try:
        response_body['family_name'] = name.split(' ', 1)[1]
    except Exception as error:
        print('[ERROR] no family_name for: ' + user_id)
        response_body['family_name'] = None

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
        conf_values = init_env_vars()
        claims = get_claims(event['headers']['Authorization'])
        user_id, name, email = get_userinfo(
            claims,
            conf_values
        )
        response_body = build_api_response(
            user_id,
            name,
            email
        )
        return {
            'statusCode': 200,
            'body': json.dumps(response_body),
            'headers': {
                'Content-Type' : 'application/json',
                'Access-Control-Allow-Origin' : '*',
                'Allow' : 'GET, OPTIONS',
                'Access-Control-Allow-Methods' : 'GET, OPTIONS',
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
                'Allow' : 'GET, OPTIONS',
                'Access-Control-Allow-Methods' : 'GET, OPTIONS',
                'Access-Control-Allow-Headers' : '*'
            },
            'isBase64Encoded': False,
        }
