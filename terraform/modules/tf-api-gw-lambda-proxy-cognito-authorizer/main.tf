data "aws_caller_identity" "current" {}

resource "aws_api_gateway_method" "api-method" {
  rest_api_id      = "${var.rest-api-id}"
  resource_id      = "${var.api-resource-id}"
  http_method      = "${var.api-http-method}"
  authorization    = "COGNITO_USER_POOLS"
  authorizer_id    = "${var.cognito-authorizer-id}"
  #authorization_scopes = ["${var.authorization-scopes}"]
  api_key_required = "${var.is-api-key-required}"
}

# Lambda permission
resource "aws_lambda_permission" "lambda-permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${var.lambda-function-name}"
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:eu-west-1:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_method.api-method.rest_api_id}/*/${aws_api_gateway_method.api-method.http_method}${var.api-resource-path}"
}

# Api Gateway Lambda Proxy integration
resource "aws_api_gateway_integration" "lambda-integration" {
  rest_api_id             = "${var.rest-api-id}"
  resource_id             = "${var.api-resource-id}"
  http_method             = "${aws_api_gateway_method.api-method.http_method}"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:eu-west-1:lambda:path/2015-03-31/functions/${var.lambda-function-arn}/invocations"
}
