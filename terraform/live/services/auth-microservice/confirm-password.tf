module "confirm-password-lambda-role-policy" {
  source                = "../../../modules/tf-iam-role-policy"
  role-policy-name      = "${var.confirm-password-lambda-function-name}-role-policy"
  role-policy-json-file = "${local.auth_microservice_path}/policies/confirm-password-lambda-role-policy.json"
  role-name             = module.confirm-password-lambda-role.iam-role-name
}

module "confirm-password-lambda-role" {
  source                      = "../../../modules/tf-iam-role"
  iam-role-name               = "${var.confirm-password-lambda-function-name}-role"
  iam-role-path               = "/"
  iam-assume-role-policy-file = "${local.auth_microservice_path}/policies/lambda-assume-role-policy.json"
}

data "archive_file" "confirm-password-zip" {
  type        = "zip"
  excludes    = ["lambda.zip"]
  source_dir  = var.confirm-password-lambda-zip-src-path
  output_path = join("", ["${local.auth_microservice_path}/", "${var.confirm-password-lambda-zip-src-path}/lambda.zip"])
}

resource "aws_lambda_function" "confirm-password-lambda" {
  filename      = join("", ["${local.auth_microservice_path}/", "${var.confirm-password-lambda-zip-src-path}/lambda.zip"])
  function_name = var.confirm-password-lambda-function-name
  handler       = var.confirm-password-lambda-entrypoint
  role          = module.confirm-password-lambda-role.iam-role-arn
  description   = var.confirm-password-lambda-function-desc
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

  source_code_hash = data.archive_file.confirm-password-zip.output_base64sha256
}

resource "aws_cloudwatch_log_group" "confirm-password-lambda-log-group" {
  name              = "/aws/lambda/${var.confirm-password-lambda-function-name}"
  retention_in_days = "1"
}

module "confirm-password-lambda-endpoint" {
  source               = "../../../modules/tf-api-gw-lambda-proxy"
  rest-api-id          = aws_api_gateway_rest_api.api-gw.id
  api-resource-path    = aws_api_gateway_resource.confirm-password.path
  api-resource-id      = aws_api_gateway_resource.confirm-password.id
  api-http-method      = "POST"
  authorization-type   = "NONE"
  authorizer-id        = ""
  is-api-key-required  = "true"
  lambda-function-name = aws_lambda_function.confirm-password-lambda.function_name
  lambda-function-arn  = aws_lambda_function.confirm-password-lambda.arn
}
