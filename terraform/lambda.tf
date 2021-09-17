variable "lambda_function_name" {
  default = "what-is-my-ip-lambda"
}

variable "deployment_package_fname" {
  default = "deployment-package.zip"
}

# FIXME: install dependencies, if you need to. Simple app, no deps.
# FIXME: run tests, if you have any. Also, good luck with that.
data "archive_file" "deployment_package" {
  type        = "zip"
  source_file = "${path.module}/../app/lambda_function.py"
  output_path = "${path.module}/${var.deployment_package_fname}"
}

resource "aws_iam_role" "wimi_lambda_svc_role" {
  name = "what-is-my-ip-lambda-service-role"
  path = "/service-role/"

  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "lambda.amazonaws.com"
          }
        },
      ]
      Version = "2012-10-17"
    }
  )
}

resource "aws_iam_policy" "wimi_lambda_logging" {
  name        = "WhatIsMyIPLambdaLoggingPolicy"
  path        = "/"
  description = "IAM policy for logging from a What Is My IP lambda."

  policy = jsonencode(
    {
      Statement = [
        {
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
          ]
          Effect   = "Allow"
          Resource = "arn:aws:logs:*:*:*"
        },
      ]
      Version = "2012-10-17"
    }
  )
}

resource "aws_iam_role_policy_attachment" "wimi_lambda_logs" {
  role       = aws_iam_role.wimi_lambda_svc_role.name
  policy_arn = aws_iam_policy.wimi_lambda_logging.arn
}

resource "aws_cloudwatch_log_group" "wimi_lambda" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 1
}

resource "aws_lambda_function" "wimi" {
  # Use S3 or some kind of "artifactory" to store previous versions without need
  # to rebuild everything from scratch which in case of Python could mean
  # completely different dependencies. Or maybe with `publish = true`.
  filename                       = "${path.module}/${var.deployment_package_fname}"
  function_name                  = var.lambda_function_name
  handler                        = "lambda_function.lambda_handler"
  memory_size                    = 128
  reserved_concurrent_executions = 10
  role                           = aws_iam_role.wimi_lambda_svc_role.arn
  runtime                        = "python3.8"
  source_code_hash               = data.archive_file.deployment_package.output_base64sha256
  timeout                        = 3

  depends_on = [
    data.archive_file.deployment_package,
    aws_iam_role_policy_attachment.wimi_lambda_logs,
    aws_cloudwatch_log_group.wimi_lambda,
  ]
}

resource "aws_lambda_permission" "apigw_invoke_wimi" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.wimi.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.wimi.execution_arn}/*/*"
}

# FIXME: replace with proper integration tests written in eg. pytest or OPA(?)
resource "null_resource" "test_wimi" {
  provisioner "local-exec" {
    command = "curl --fail --show-error --silent '${aws_api_gateway_deployment.wimi.invoke_url}'"
  }

  depends_on = [
    aws_lambda_function.wimi,
    aws_api_gateway_deployment.wimi,
  ]
}
