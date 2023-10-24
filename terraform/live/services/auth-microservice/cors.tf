module "login-endpoint" {
  source           = "../../../modules/tf-api-gw-cors"
  rest-api-id      = aws_api_gateway_rest_api.api-gw.id
  api-resource-id  = aws_api_gateway_resource.login.id
  api-http-methods = ["POST"]
}

module "logout-endpoint" {
  source           = "../../../modules/tf-api-gw-cors"
  rest-api-id      = aws_api_gateway_rest_api.api-gw.id
  api-resource-id  = aws_api_gateway_resource.logout.id
  api-http-methods = ["POST"]
}

module "mfa-verify-endpoint" {
  source           = "../../../modules/tf-api-gw-cors"
  rest-api-id      = aws_api_gateway_rest_api.api-gw.id
  api-resource-id  = aws_api_gateway_resource.mfa-verify.id
  api-http-methods = ["POST"]
}

module "refresh-token-endpoint" {
  source           = "../../../modules/tf-api-gw-cors"
  rest-api-id      = aws_api_gateway_rest_api.api-gw.id
  api-resource-id  = aws_api_gateway_resource.refresh-token.id
  api-http-methods = ["POST"]
}

module "resend-confirmation-code-endpoint" {
  source           = "../../../modules/tf-api-gw-cors"
  rest-api-id      = aws_api_gateway_rest_api.api-gw.id
  api-resource-id  = aws_api_gateway_resource.resend-confirmation-code.id
  api-http-methods = ["POST"]
}

module "resend-mfa-endpoint" {
  source           = "../../../modules/tf-api-gw-cors"
  rest-api-id      = aws_api_gateway_rest_api.api-gw.id
  api-resource-id  = aws_api_gateway_resource.resend-mfa.id
  api-http-methods = ["POST"]
}

module "change-password-endpoint" {
  source           = "../../../modules/tf-api-gw-cors"
  rest-api-id      = aws_api_gateway_rest_api.api-gw.id
  api-resource-id  = aws_api_gateway_resource.change-password.id
  api-http-methods = ["POST"]
}

module "create-user-endpoint" {
  source           = "../../../modules/tf-api-gw-cors"
  rest-api-id      = aws_api_gateway_rest_api.api-gw.id
  api-resource-id  = aws_api_gateway_resource.users.id
  api-http-methods = ["POST"]
}

module "confirm-user-endpoint" {
  source           = "../../../modules/tf-api-gw-cors"
  rest-api-id      = aws_api_gateway_rest_api.api-gw.id
  api-resource-id  = aws_api_gateway_resource.confirm.id
  api-http-methods = ["POST"]
}

module "confirm-mfa-endpoint" {
  source           = "../../../modules/tf-api-gw-cors"
  rest-api-id      = aws_api_gateway_rest_api.api-gw.id
  api-resource-id  = aws_api_gateway_resource.confirm-mfa.id
  api-http-methods = ["POST"]
}

module "reset-password-endpoint" {
  source           = "../../../modules/tf-api-gw-cors"
  rest-api-id      = aws_api_gateway_rest_api.api-gw.id
  api-resource-id  = aws_api_gateway_resource.reset-password.id
  api-http-methods = ["POST"]
}

module "forgot-password-endpoint" {
  source           = "../../../modules/tf-api-gw-cors"
  rest-api-id      = aws_api_gateway_rest_api.api-gw.id
  api-resource-id  = aws_api_gateway_resource.forgot-password.id
  api-http-methods = ["POST"]
}

module "confirm-password-endpoint" {
  source           = "../../../modules/tf-api-gw-cors"
  rest-api-id      = aws_api_gateway_rest_api.api-gw.id
  api-resource-id  = aws_api_gateway_resource.confirm-password.id
  api-http-methods = ["POST"]
}

module "userinfo-endpoint" {
  source           = "../../../modules/tf-api-gw-cors"
  rest-api-id      = aws_api_gateway_rest_api.api-gw.id
  api-resource-id  = aws_api_gateway_resource.userinfo.id
  api-http-methods = ["GET"]
}

module "delete-user-endpoint" {
  source           = "../../../modules/tf-api-gw-cors"
  rest-api-id      = aws_api_gateway_rest_api.api-gw.id
  api-resource-id  = aws_api_gateway_resource.user-id.id
  api-http-methods = ["DELETE"]
}
