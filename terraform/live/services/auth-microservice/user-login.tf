module "user-login-lambda-role-policy" {
  source                = "../../../modules/tf-iam-role-policy"
  role-policy-name      = "${var.user-login-lambda-function-name}-role-policy"
  role-policy-json-file = "${local.auth_microservice_path}/policies/user-login-lambda-role-policy.json"
  role-name             = module.user-login-lambda-role.iam-role-name
}

module "user-login-lambda-role" {
  source                      = "../../../modules/tf-iam-role"
  iam-role-name               = "${var.user-login-lambda-function-name}-role"
  iam-role-path               = "/"
  iam-assume-role-policy-file = "${local.auth_microservice_path}/policies/lambda-assume-role-policy.json"
}

data "archive_file" "user-login-zip" {
  type        = "zip"
  excludes    = ["lambda.zip"]
  source_dir  = var.user-login-lambda-zip-src-path
  output_path = join("", ["${local.auth_microservice_path}/", "${var.user-login-lambda-zip-src-path}/lambda.zip"])
}

resource "aws_lambda_function" "user-login-lambda" {
  filename      = join("", ["${local.auth_microservice_path}/", "${var.user-login-lambda-zip-src-path}/lambda.zip"])
  function_name = var.user-login-lambda-function-name
  handler       = var.user-login-lambda-entrypoint
  role          = module.user-login-lambda-role.iam-role-arn
  description   = var.user-login-lambda-function-desc
  memory_size   = var.auth-lambdas-memory-size
  runtime       = var.auth-lambdas-runtime
  timeout       = var.auth-lambdas-timeout
  layers        = [aws_lambda_layer_version.jsonschema.arn]

  environment {
    variables = {
      COGNITO_USER_POOL_ID  = module.user-pool.user-pool-id
      COGNITO_APP_CLIENT_ID = module.user-pool.user-pool-client-id
    }
  }

  source_code_hash = data.archive_file.user-login-zip.output_base64sha256
}

resource "aws_cloudwatch_log_group" "user-login-lambda-log-group" {
  name              = "/aws/lambda/${var.user-login-lambda-function-name}"
  retention_in_days = "1"
}

module "user-login-lambda-endpoint" {
  source               = "../../../modules/tf-api-gw-lambda-proxy"
  rest-api-id          = aws_api_gateway_rest_api.api-gw.id
  api-resource-path    = aws_api_gateway_resource.login.path
  api-resource-id      = aws_api_gateway_resource.login.id
  api-http-method      = "POST"
  authorization-type   = "NONE"
  authorizer-id        = ""
  is-api-key-required  = "true"
  lambda-function-name = aws_lambda_function.user-login-lambda.function_name
  lambda-function-arn  = aws_lambda_function.user-login-lambda.arn
}
