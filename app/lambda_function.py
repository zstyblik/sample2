#!/usr/bin/env python3
"""Simple lambda function which return client's IP address."""
import json
import logging
import sys
import traceback


print("Loading function")


def lambda_handler(event, context):
    """Handle AWS Lambda function invocation."""
    logging.basicConfig(level=logging.INFO, stream=sys.stdout)
    try:
        req_context = event.get("requestContext", None)
        method = req_context.get("httpMethod", None)
        if method != "GET":
            return {
                "statusCode": 405,
                "headers": {"Content-Type": "text/plain"},
                "body": "Method Not Allowed",
            }

        identity = req_context.get("identity", {})
        source_ip = identity.get("sourceIp", None)
        message = {
            "ip_address": source_ip,
        }
        return {
            "statusCode": 200,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps(message),
        }
    except Exception as exception:
        logging.error("Exception '%s' occurred for event: %s", exception, event)
        logging.error("Exception occurred: %s", traceback.format_exc())
        return {
            "statusCode": 500,
            "headers": {"Content-Type": "text/plain"},
            "body": "500 Internal Server Error",
        }
