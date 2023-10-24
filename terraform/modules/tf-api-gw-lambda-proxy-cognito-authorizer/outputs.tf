output "api-method-id" {
  value = aws_api_gateway_method.api-method.id
}

output "lambda-integration-id" {
  value = aws_api_gateway_integration.lambda-integration.id
}
