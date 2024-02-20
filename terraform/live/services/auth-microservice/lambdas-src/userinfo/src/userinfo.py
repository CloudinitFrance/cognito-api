#! /usr/bin/env python
'''Get user infos'''

import os
import json
import collections
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


def build_api_response(claims):
    '''Build the API response'''
    response_body = collections.OrderedDict()
    if 'name' in claims:
        response_body['name'] = claims['name']
    else:
        response_body['name'] = None
    if 'sub' in claims:
        response_body['user_id'] = claims['sub']
    else:
        response_body['user_id'] = None
    if 'email' in claims:
        response_body['email'] = claims['email']
    else:
        response_body['email'] = None
    if 'phone_number' in claims:
        response_body['phone_number'] = claims['phone_number']
    else:
        response_body['phone_number'] = None
    if 'cognito:groups' in claims:
        response_body['groups'] = claims['cognito:groups']
    else:
        response_body['groups'] = []

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
        response_body = build_api_response(
            claims
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
