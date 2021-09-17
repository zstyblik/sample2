"""Simple lambda function which return client's IP address."""
import json
import logging
import sys


print("Loading function")


def lambda_handler(event, context):
    """Handle AWS Lambda function invocation."""
    logging.basicConfig(level=logging.INFO, stream=sys.stdout)
    logging.debug("Received event")
    logging.debug("Received event: %s", json.dumps(event, indent=2))

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
