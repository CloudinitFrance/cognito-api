module "userinfo-lambda-role-policy" {
  source                = "../../../modules/tf-iam-role-policy"
  role-policy-name      = "${var.userinfo-lambda-function-name}-role-policy"
  role-policy-json-file = "${local.auth_microservice_path}/policies/userinfo-lambda-role-policy.json"
  role-name             = module.userinfo-lambda-role.iam-role-name
}

module "userinfo-lambda-role" {
  source                      = "../../../modules/tf-iam-role"
  iam-role-name               = "${var.userinfo-lambda-function-name}-role"
  iam-role-path               = "/"
  iam-assume-role-policy-file = "${local.auth_microservice_path}/policies/lambda-assume-role-policy.json"
}

data "archive_file" "userinfo-zip" {
  type        = "zip"
  excludes    = ["lambda.zip"]
  source_dir  = var.userinfo-lambda-zip-src-path
  output_path = join("", ["${local.auth_microservice_path}/", "${var.userinfo-lambda-zip-src-path}/lambda.zip"])
}

resource "aws_lambda_function" "userinfo-lambda" {
  filename      = join("", ["${local.auth_microservice_path}/", "${var.userinfo-lambda-zip-src-path}/lambda.zip"])
  function_name = var.userinfo-lambda-function-name
  handler       = var.userinfo-lambda-entrypoint
  role          = module.userinfo-lambda-role.iam-role-arn
  description   = var.userinfo-lambda-function-desc
  memory_size   = var.auth-lambdas-memory-size
  runtime       = var.auth-lambdas-runtime
  timeout       = var.auth-lambdas-timeout
  layers        = [aws_lambda_layer_version.jsonschema.arn, aws_lambda_layer_version.pyjwt.arn]

  environment {
    variables = {
      COGNITO_USER_POOL_ID = module.user-pool.user-pool-id
    }
  }

  source_code_hash = data.archive_file.userinfo-zip.output_base64sha256
}

resource "aws_cloudwatch_log_group" "userinfo-lambda-log-group" {
  name              = "/aws/lambda/${var.userinfo-lambda-function-name}"
  retention_in_days = "1"
}

module "userinfo-lambda-endpoint" {
  source                = "../../../modules/tf-api-gw-lambda-proxy-cognito-authorizer"
  rest-api-id           = aws_api_gateway_rest_api.api-gw.id
  api-resource-path     = aws_api_gateway_resource.userinfo.path
  api-resource-id       = aws_api_gateway_resource.userinfo.id
  api-http-method       = "GET"
  cognito-authorizer-id = aws_api_gateway_authorizer.cognito-authorizer.id
  is-api-key-required   = "true"
  lambda-function-name  = aws_lambda_function.userinfo-lambda.function_name
  lambda-function-arn   = aws_lambda_function.userinfo-lambda.arn
}
