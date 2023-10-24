module "resend-mfa-lambda-role-policy" {
  source                = "../../../modules/tf-iam-role-policy"
  role-policy-name      = "${var.resend-mfa-lambda-function-name}-role-policy"
  role-policy-json-file = "${local.auth_microservice_path}/policies/resend-mfa-lambda-role-policy.json"
  role-name             = module.resend-mfa-lambda-role.iam-role-name
}

module "resend-mfa-lambda-role" {
  source                      = "../../../modules/tf-iam-role"
  iam-role-name               = "${var.resend-mfa-lambda-function-name}-role"
  iam-role-path               = "/"
  iam-assume-role-policy-file = "${local.auth_microservice_path}/policies/lambda-assume-role-policy.json"
}

data "archive_file" "resend-mfa-zip" {
  type        = "zip"
  excludes    = ["lambda.zip"]
  source_dir  = var.resend-mfa-lambda-zip-src-path
  output_path = join("", ["${local.auth_microservice_path}/", "${var.resend-mfa-lambda-zip-src-path}/lambda.zip"])
}

resource "aws_lambda_function" "resend-mfa-lambda" {
  filename      = join("", ["${local.auth_microservice_path}/", "${var.resend-mfa-lambda-zip-src-path}/lambda.zip"])
  function_name = var.resend-mfa-lambda-function-name
  handler       = var.resend-mfa-lambda-entrypoint
  role          = module.resend-mfa-lambda-role.iam-role-arn
  description   = var.resend-mfa-lambda-function-desc
  memory_size   = var.auth-lambdas-memory-size
  runtime       = var.auth-lambdas-runtime
  timeout       = var.auth-lambdas-timeout
  layers        = [aws_lambda_layer_version.jsonschema.arn]

  environment {
    variables = {
      S3_BUCKET_MFA_BUCKET = "${module.auth-mfa.s3-id}"
      USERS_MFA_FOLDER     = "${var.users-mfa-folder}"
      FROM_EMAIL           = "${var.from-email}"
      COGNITO_USER_POOL_ID = module.user-pool.user-pool-id
    }
  }

  source_code_hash = data.archive_file.resend-mfa-zip.output_base64sha256
}

resource "aws_cloudwatch_log_group" "resend-mfa-lambda-log-group" {
  name              = "/aws/lambda/${var.resend-mfa-lambda-function-name}"
  retention_in_days = "1"
}

module "resend-mfa-lambda-endpoint" {
  source               = "../../../modules/tf-api-gw-lambda-proxy"
  rest-api-id          = aws_api_gateway_rest_api.api-gw.id
  api-resource-path    = aws_api_gateway_resource.resend-mfa.path
  api-resource-id      = aws_api_gateway_resource.resend-mfa.id
  api-http-method      = "POST"
  authorization-type   = "NONE"
  authorizer-id        = ""
  is-api-key-required  = "true"
  lambda-function-name = aws_lambda_function.resend-mfa-lambda.function_name
  lambda-function-arn  = aws_lambda_function.resend-mfa-lambda.arn
}
