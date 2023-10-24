resource "aws_api_gateway_authorizer" "cognito-authorizer" {
  name          = var.cognito-authorizer-name
  type          = "COGNITO_USER_POOLS"
  rest_api_id   = aws_api_gateway_rest_api.api-gw.id
  provider_arns = ["arn:aws:cognito-idp:${var.aws-region}:${data.aws_caller_identity.current.account_id}:userpool/${module.user-pool.user-pool-id}"]
}
