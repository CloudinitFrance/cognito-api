# Use this link:
# https://docs.aws.amazon.com/cognito/latest/developerguide/user-pool-lambda-custom-message.html
# To customize: lambdas-src/custom-message/src/custom_message.js

module "custom-message-lambda-role-policy" {
  source                = "../../../modules/tf-iam-role-policy"
  role-policy-name      = "${var.custom-message-lambda-function-name}-role-policy"
  role-policy-json-file = "${local.auth_microservice_path}/policies/custom-message-lambda-role-policy.json"
  role-name             = module.custom-message-lambda-role.iam-role-name
}

module "custom-message-lambda-role" {
  source                      = "../../../modules/tf-iam-role"
  iam-role-name               = "${var.custom-message-lambda-function-name}-role"
  iam-role-path               = "/"
  iam-assume-role-policy-file = "${local.auth_microservice_path}/policies/lambda-assume-role-policy.json"
}

data "archive_file" "custom-message-zip" {
  type     = "zip"
  excludes = ["lambda.zip"]
  #source_dir  = var.custom-message-lambda-zip-src-path
  source_dir  = join("", ["${local.auth_microservice_path}/", "${var.custom-message-lambda-zip-src-path}"])
  output_path = join("", ["${local.auth_microservice_path}/", "${var.custom-message-lambda-zip-src-path}/lambda.zip"])
}

resource "aws_lambda_function" "custom-message-lambda" {
  filename      = join("", ["${local.auth_microservice_path}/", "${var.custom-message-lambda-zip-src-path}/lambda.zip"])
  function_name = var.custom-message-lambda-function-name
  handler       = var.custom-message-lambda-entrypoint
  role          = module.custom-message-lambda-role.iam-role-arn
  description   = var.custom-message-lambda-function-desc
  memory_size   = var.custom-message-lambda-memory-size
  runtime       = var.custom-message-lambda-runtime
  timeout       = var.custom-message-lambda-timeout

  source_code_hash = data.archive_file.custom-message-zip.output_base64sha256
}

resource "aws_cloudwatch_log_group" "custom-message-lambda-log-group" {
  name              = "/aws/lambda/${var.custom-message-lambda-function-name}"
  retention_in_days = "1"
}

resource "aws_lambda_permission" "allow_execution_from_user_pool" {
  statement_id  = "AllowExecutionFromUserPool"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.custom-message-lambda.function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = module.user-pool.user-pool-arn
}
