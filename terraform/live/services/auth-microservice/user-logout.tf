module "user-logout-lambda-role-policy" {
  source                = "../../../modules/tf-iam-role-policy"
  role-policy-name      = "${var.user-logout-lambda-function-name}-role-policy"
  role-policy-json-file = "${local.auth_microservice_path}/policies/user-logout-lambda-role-policy.json"
  role-name             = module.user-logout-lambda-role.iam-role-name
}

module "user-logout-lambda-role" {
  source                      = "../../../modules/tf-iam-role"
  iam-role-name               = "${var.user-logout-lambda-function-name}-role"
  iam-role-path               = "/"
  iam-assume-role-policy-file = "${local.auth_microservice_path}/policies/lambda-assume-role-policy.json"
}

data "archive_file" "user-logout-zip" {
  type        = "zip"
  excludes    = ["lambda.zip"]
  source_dir  = var.user-logout-lambda-zip-src-path
  output_path = join("", ["${local.auth_microservice_path}/", "${var.user-logout-lambda-zip-src-path}/lambda.zip"])
}

resource "aws_lambda_function" "user-logout-lambda" {
  filename      = join("", ["${local.auth_microservice_path}/", "${var.user-logout-lambda-zip-src-path}/lambda.zip"])
  function_name = var.user-logout-lambda-function-name
  handler       = var.user-logout-lambda-entrypoint
  role          = module.user-logout-lambda-role.iam-role-arn
  description   = var.user-logout-lambda-function-desc
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

  source_code_hash = data.archive_file.user-logout-zip.output_base64sha256
}

resource "aws_cloudwatch_log_group" "user-logout-lambda-log-group" {
  name              = "/aws/lambda/${var.user-logout-lambda-function-name}"
  retention_in_days = "1"
}

module "user-logout-lambda-endpoint" {
  source               = "../../../modules/tf-api-gw-lambda-proxy"
  rest-api-id          = aws_api_gateway_rest_api.api-gw.id
  api-resource-path    = aws_api_gateway_resource.logout.path
  api-resource-id      = aws_api_gateway_resource.logout.id
  api-http-method      = "POST"
  authorization-type   = "NONE"
  authorizer-id        = ""
  is-api-key-required  = "true"
  lambda-function-name = aws_lambda_function.user-logout-lambda.function_name
  lambda-function-arn  = aws_lambda_function.user-logout-lambda.arn
}
