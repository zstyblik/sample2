resource "aws_api_gateway_rest_api" "wimi" {
  name        = "what-is-my-ip-lambda-apigw"
  description = "API Gateway for What Is My IP lambda function"
}

resource "aws_api_gateway_resource" "wimi_proxy" {
  rest_api_id = aws_api_gateway_rest_api.wimi.id
  parent_id   = aws_api_gateway_rest_api.wimi.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "wimi_proxy" {
  rest_api_id   = aws_api_gateway_rest_api.wimi.id
  resource_id   = aws_api_gateway_resource.wimi_proxy.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "wimi_lambda" {
  rest_api_id = aws_api_gateway_rest_api.wimi.id
  resource_id = aws_api_gateway_method.wimi_proxy.resource_id
  http_method = aws_api_gateway_method.wimi_proxy.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.wimi.invoke_arn
}

resource "aws_api_gateway_method" "wimi_proxy_root" {
  rest_api_id   = aws_api_gateway_rest_api.wimi.id
  resource_id   = aws_api_gateway_rest_api.wimi.root_resource_id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "wimi_lambda_root" {
  rest_api_id = aws_api_gateway_rest_api.wimi.id
  resource_id = aws_api_gateway_method.wimi_proxy_root.resource_id
  http_method = aws_api_gateway_method.wimi_proxy_root.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.wimi.invoke_arn
}

resource "aws_api_gateway_deployment" "wimi" {
  depends_on = [
    aws_api_gateway_integration.wimi_lambda,
    aws_api_gateway_integration.wimi_lambda_root,
  ]

  rest_api_id = aws_api_gateway_rest_api.wimi.id
  stage_name  = "ip"
}
