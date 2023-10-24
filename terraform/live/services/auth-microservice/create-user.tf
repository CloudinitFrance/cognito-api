module "create-user-lambda-role-policy" {
  source                = "../../../modules/tf-iam-role-policy"
  role-policy-name      = "${var.create-user-lambda-function-name}-role-policy"
  role-policy-json-file = "${local.auth_microservice_path}/policies/create-user-lambda-role-policy.json"
  role-name             = module.create-user-lambda-role.iam-role-name
}

module "create-user-lambda-role" {
  source                      = "../../../modules/tf-iam-role"
  iam-role-name               = "${var.create-user-lambda-function-name}-role"
  iam-role-path               = "/"
  iam-assume-role-policy-file = "${local.auth_microservice_path}/policies/lambda-assume-role-policy.json"
}

data "archive_file" "create-user-zip" {
  type        = "zip"
  excludes    = ["lambda.zip"]
  source_dir  = var.create-user-lambda-zip-src-path
  output_path = join("", ["${local.auth_microservice_path}/", "${var.create-user-lambda-zip-src-path}/lambda.zip"])
}

resource "aws_lambda_function" "create-user-lambda" {
  filename      = join("", ["${local.auth_microservice_path}/", "${var.create-user-lambda-zip-src-path}/lambda.zip"])
  function_name = var.create-user-lambda-function-name
  handler       = var.create-user-lambda-entrypoint
  role          = module.create-user-lambda-role.iam-role-arn
  description   = var.create-user-lambda-function-desc
  memory_size   = var.auth-lambdas-memory-size
  runtime       = var.auth-lambdas-runtime
  timeout       = var.auth-lambdas-timeout
  layers        = [aws_lambda_layer_version.jsonschema.arn]

  environment {
    variables = {
      COGNITO_USER_POOL_ID = module.user-pool.user-pool-id
    }
  }

  source_code_hash = data.archive_file.create-user-zip.output_base64sha256
}

resource "aws_cloudwatch_log_group" "create-user-lambda-log-group" {
  name              = "/aws/lambda/${var.create-user-lambda-function-name}"
  retention_in_days = "1"
}

module "create-user-lambda-endpoint" {
  source               = "../../../modules/tf-api-gw-lambda-proxy"
  rest-api-id          = aws_api_gateway_rest_api.api-gw.id
  api-resource-path    = aws_api_gateway_resource.users.path
  api-resource-id      = aws_api_gateway_resource.users.id
  api-http-method      = "POST"
  authorization-type   = "NONE"
  authorizer-id        = ""
  is-api-key-required  = "true"
  lambda-function-name = aws_lambda_function.create-user-lambda.function_name
  lambda-function-arn  = aws_lambda_function.create-user-lambda.arn
}
