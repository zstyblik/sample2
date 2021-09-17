"""Tests related to lambda_function.py."""
import json

import lambda_function
import pytest


@pytest.mark.parametrize(
    "source_ip", ["127.0.0.1", "::1/128", "abcedfg", 0.1, 12345,]
)
def test_lambda_handler_valid_data(source_ip):
    """Test handling of unexpected exception."""
    message = {"ip_address": source_ip}
    expected_result = {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(message),
    }
    event = {
        "requestContext": {
            "httpMethod": "GET",
            "identity": {"sourceIp": source_ip},
        }
    }
    context = None
    result = lambda_function.lambda_handler(event, context)
    assert result == expected_result


@pytest.mark.parametrize(
    "event",
    ["abc", {"requestContext": {"httpMethod": "GET", "identity": "abc"}}, {},],
)
def test_lambda_handler_unexpected_exceptions(event):
    """Test handling of unexpected exception."""
    expected_result = {
        "statusCode": 500,
        "headers": {"Content-Type": "text/plain"},
        "body": "500 Internal Server Error",
    }
    context = None
    result = lambda_function.lambda_handler(event, context)
    assert result == expected_result


@pytest.mark.parametrize(
    "method", ["BLABLA", "DELETE", "OPTIONS", "POST", "PUT", 0, None,]
)
def test__lambda_handler_unsupported_methods(method):
    """Test handling of HTTP methods other than GET method."""
    expected_result = {
        "statusCode": 405,
        "headers": {"Content-Type": "text/plain"},
        "body": "Method Not Allowed",
    }
    event = {"requestContext": {"httpMethod": method}}
    context = None
    result = lambda_function.lambda_handler(event, context)
    assert result == expected_result
