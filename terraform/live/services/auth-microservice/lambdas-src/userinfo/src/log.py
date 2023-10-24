#! /usr/bin/env python
# -*- coding: utf-8 -*-
'''Just a simple logger'''

import logging


def setup_logging():
    '''Hmmm setup logging'''
    logger = logging.getLogger()
    for handler in logger.handlers:
        logger.removeHandler(handler)

    handler = logging.StreamHandler()

    log_format = '%(asctime)s - %(funcName)s - %(levelname)s - %(message)s'
    handler.setFormatter(logging.Formatter(log_format))
    logger.addHandler(handler)
    logger.setLevel(logging.INFO)

    return logger
