output "base_url" {
  value = "curl ${aws_api_gateway_deployment.wimi.invoke_url}"
}
