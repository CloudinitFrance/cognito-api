module "confirm-mfa-lambda-role-policy" {
  source                = "../../../modules/tf-iam-role-policy"
  role-policy-name      = "${var.confirm-mfa-lambda-function-name}-role-policy"
  role-policy-json-file = "${local.auth_microservice_path}/policies/confirm-mfa-lambda-role-policy.json"
  role-name             = module.confirm-mfa-lambda-role.iam-role-name
}

module "confirm-mfa-lambda-role" {
  source                      = "../../../modules/tf-iam-role"
  iam-role-name               = "${var.confirm-mfa-lambda-function-name}-role"
  iam-role-path               = "/"
  iam-assume-role-policy-file = "${local.auth_microservice_path}/policies/lambda-assume-role-policy.json"
}

data "archive_file" "confirm-mfa-zip" {
  type        = "zip"
  excludes    = ["lambda.zip"]
  source_dir  = var.confirm-mfa-lambda-zip-src-path
  output_path = join("", ["${local.auth_microservice_path}/", "${var.confirm-mfa-lambda-zip-src-path}/lambda.zip"])
}

resource "aws_lambda_function" "confirm-mfa-lambda" {
  filename      = join("", ["${local.auth_microservice_path}/", "${var.confirm-mfa-lambda-zip-src-path}/lambda.zip"])
  function_name = var.confirm-mfa-lambda-function-name
  handler       = var.confirm-mfa-lambda-entrypoint
  role          = module.confirm-mfa-lambda-role.iam-role-arn
  description   = var.confirm-mfa-lambda-function-desc
  memory_size   = var.auth-lambdas-memory-size
  runtime       = var.auth-lambdas-runtime
  timeout       = var.auth-lambdas-timeout
  layers        = [aws_lambda_layer_version.jsonschema.arn, aws_lambda_layer_version.pillow.arn, aws_lambda_layer_version.pyotp.arn, aws_lambda_layer_version.qrcode.arn, aws_lambda_layer_version.opencv.arn]

  environment {
    variables = {
      COGNITO_USER_POOL_ID  = module.user-pool.user-pool-id
      COGNITO_APP_CLIENT_ID = module.user-pool.user-pool-client-id
      S3_BUCKET_MFA_BUCKET  = "${module.auth-mfa.s3-id}"
    }
  }

  source_code_hash = data.archive_file.confirm-mfa-zip.output_base64sha256
}

resource "aws_cloudwatch_log_group" "confirm-mfa-lambda-log-group" {
  name              = "/aws/lambda/${var.confirm-mfa-lambda-function-name}"
  retention_in_days = "1"
}

module "confirm-mfa-lambda-endpoint" {
  source               = "../../../modules/tf-api-gw-lambda-proxy"
  rest-api-id          = aws_api_gateway_rest_api.api-gw.id
  api-resource-path    = aws_api_gateway_resource.confirm-mfa.path
  api-resource-id      = aws_api_gateway_resource.confirm-mfa.id
  api-http-method      = "POST"
  authorization-type   = "NONE"
  authorizer-id        = ""
  is-api-key-required  = "true"
  lambda-function-name = aws_lambda_function.confirm-mfa-lambda.function_name
  lambda-function-arn  = aws_lambda_function.confirm-mfa-lambda.arn
}
