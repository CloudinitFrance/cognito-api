module "resend-confirmation-code-lambda-role-policy" {
  source                = "../../../modules/tf-iam-role-policy"
  role-policy-name      = "${var.resend-confirmation-code-lambda-function-name}-role-policy"
  role-policy-json-file = "${local.auth_microservice_path}/policies/resend-confirmation-code-lambda-role-policy.json"
  role-name             = module.resend-confirmation-code-lambda-role.iam-role-name
}

module "resend-confirmation-code-lambda-role" {
  source                      = "../../../modules/tf-iam-role"
  iam-role-name               = "${var.resend-confirmation-code-lambda-function-name}-role"
  iam-role-path               = "/"
  iam-assume-role-policy-file = "${local.auth_microservice_path}/policies/lambda-assume-role-policy.json"
}

data "archive_file" "resend-confirmation-code-zip" {
  type        = "zip"
  excludes    = ["lambda.zip"]
  source_dir  = var.resend-confirmation-code-lambda-zip-src-path
  output_path = join("", ["${local.auth_microservice_path}/", "${var.resend-confirmation-code-lambda-zip-src-path}/lambda.zip"])
}

resource "aws_lambda_function" "resend-confirmation-code-lambda" {
  filename      = join("", ["${local.auth_microservice_path}/", "${var.resend-confirmation-code-lambda-zip-src-path}/lambda.zip"])
  function_name = var.resend-confirmation-code-lambda-function-name
  handler       = var.resend-confirmation-code-lambda-entrypoint
  role          = module.resend-confirmation-code-lambda-role.iam-role-arn
  description   = var.resend-confirmation-code-lambda-function-desc
  memory_size   = var.auth-lambdas-memory-size
  runtime       = var.auth-lambdas-runtime
  timeout       = var.auth-lambdas-timeout
  layers        = [aws_lambda_layer_version.jsonschema.arn]

  environment {
    variables = {
      COGNITO_USER_POOL_ID = module.user-pool.user-pool-id
    }
  }

  source_code_hash = data.archive_file.resend-confirmation-code-zip.output_base64sha256
}

resource "aws_cloudwatch_log_group" "resend-confirmation-code-lambda-log-group" {
  name              = "/aws/lambda/${var.resend-confirmation-code-lambda-function-name}"
  retention_in_days = "1"
}

module "resend-confirmation-code-lambda-endpoint" {
  source               = "../../../modules/tf-api-gw-lambda-proxy"
  rest-api-id          = aws_api_gateway_rest_api.api-gw.id
  api-resource-path    = aws_api_gateway_resource.resend-confirmation-code.path
  api-resource-id      = aws_api_gateway_resource.resend-confirmation-code.id
  api-http-method      = "POST"
  authorization-type   = "NONE"
  authorizer-id        = ""
  is-api-key-required  = "true"
  lambda-function-name = aws_lambda_function.resend-confirmation-code-lambda.function_name
  lambda-function-arn  = aws_lambda_function.resend-confirmation-code-lambda.arn
}
