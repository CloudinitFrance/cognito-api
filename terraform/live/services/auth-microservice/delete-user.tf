module "delete-user-lambda-role-policy" {
  source                = "../../../modules/tf-iam-role-policy"
  role-policy-name      = "${var.delete-user-lambda-function-name}-role-policy"
  role-policy-json-file = "${local.auth_microservice_path}/policies/delete-user-lambda-role-policy.json"
  role-name             = module.delete-user-lambda-role.iam-role-name
}

module "delete-user-lambda-role" {
  source                      = "../../../modules/tf-iam-role"
  iam-role-name               = "${var.delete-user-lambda-function-name}-role"
  iam-role-path               = "/"
  iam-assume-role-policy-file = "${local.auth_microservice_path}/policies/lambda-assume-role-policy.json"
}

data "archive_file" "delete-user-zip" {
  type        = "zip"
  excludes    = ["lambda.zip"]
  source_dir  = var.delete-user-lambda-zip-src-path
  output_path = join("", ["${local.auth_microservice_path}/", "${var.delete-user-lambda-zip-src-path}/lambda.zip"])
}

resource "aws_lambda_function" "delete-user-lambda" {
  filename      = join("", ["${local.auth_microservice_path}/", "${var.delete-user-lambda-zip-src-path}/lambda.zip"])
  function_name = var.delete-user-lambda-function-name
  handler       = var.delete-user-lambda-entrypoint
  role          = module.delete-user-lambda-role.iam-role-arn
  description   = var.delete-user-lambda-function-desc
  memory_size   = var.auth-lambdas-memory-size
  runtime       = var.auth-lambdas-runtime
  timeout       = var.auth-lambdas-timeout
  layers        = [aws_lambda_layer_version.jsonschema.arn, aws_lambda_layer_version.pyjwt.arn]

  environment {
    variables = {
      COGNITO_USER_POOL_ID = module.user-pool.user-pool-id
    }
  }

  source_code_hash = data.archive_file.delete-user-zip.output_base64sha256
}

resource "aws_cloudwatch_log_group" "delete-user-lambda-log-group" {
  name              = "/aws/lambda/${var.delete-user-lambda-function-name}"
  retention_in_days = "1"
}

module "delete-user-lambda-endpoint" {
  source                = "../../../modules/tf-api-gw-lambda-proxy-cognito-authorizer"
  rest-api-id           = aws_api_gateway_rest_api.api-gw.id
  api-resource-path     = aws_api_gateway_resource.user-id.path
  api-resource-id       = aws_api_gateway_resource.user-id.id
  api-http-method       = "DELETE"
  cognito-authorizer-id = aws_api_gateway_authorizer.cognito-authorizer.id
  is-api-key-required   = "true"
  lambda-function-name  = aws_lambda_function.delete-user-lambda.function_name
  lambda-function-arn   = aws_lambda_function.delete-user-lambda.arn
}
