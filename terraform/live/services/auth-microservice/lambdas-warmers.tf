module "user-login-lambda-warmer" {
  source                            = "../../../modules/tf-lambda-cloudwatch-event-trigger"
  cw-event-rule-name                = "${var.user-login-lambda-function-name}-warmer"
  cw-event-rule-description         = "${var.user-login-lambda-function-name} cloudwatch warmer"
  cw-event-rule-schedule-expression = "rate(10 minutes)"
  lambda-arn                        = aws_lambda_function.user-login-lambda.arn
  lambda-function-name              = aws_lambda_function.user-login-lambda.function_name
}

module "user-logout-lambda-warmer" {
  source                            = "../../../modules/tf-lambda-cloudwatch-event-trigger"
  cw-event-rule-name                = "${var.user-logout-lambda-function-name}-warmer"
  cw-event-rule-description         = "${var.user-logout-lambda-function-name} cloudwatch warmer"
  cw-event-rule-schedule-expression = "rate(10 minutes)"
  lambda-arn                        = aws_lambda_function.user-logout-lambda.arn
  lambda-function-name              = aws_lambda_function.user-logout-lambda.function_name
}

module "refresh-token-lambda-warmer" {
  source                            = "../../../modules/tf-lambda-cloudwatch-event-trigger"
  cw-event-rule-name                = "${var.refresh-token-lambda-function-name}-warmer"
  cw-event-rule-description         = "${var.refresh-token-lambda-function-name} cloudwatch warmer"
  cw-event-rule-schedule-expression = "rate(10 minutes)"
  lambda-arn                        = aws_lambda_function.refresh-token-lambda.arn
  lambda-function-name              = aws_lambda_function.refresh-token-lambda.function_name
}

module "mfa-verify-lambda-warmer" {
  source                            = "../../../modules/tf-lambda-cloudwatch-event-trigger"
  cw-event-rule-name                = "${var.mfa-verify-lambda-function-name}-warmer"
  cw-event-rule-description         = "${var.mfa-verify-lambda-function-name} cloudwatch warmer"
  cw-event-rule-schedule-expression = "rate(10 minutes)"
  lambda-arn                        = aws_lambda_function.mfa-verify-lambda.arn
  lambda-function-name              = aws_lambda_function.mfa-verify-lambda.function_name
}

module "resend-mfa-lambda-warmer" {
  source                            = "../../../modules/tf-lambda-cloudwatch-event-trigger"
  cw-event-rule-name                = "${var.resend-mfa-lambda-function-name}-warmer"
  cw-event-rule-description         = "${var.resend-mfa-lambda-function-name} cloudwatch warmer"
  cw-event-rule-schedule-expression = "rate(10 minutes)"
  lambda-arn                        = aws_lambda_function.resend-mfa-lambda.arn
  lambda-function-name              = aws_lambda_function.resend-mfa-lambda.function_name
}

module "resend-confirmation-code-lambda-warmer" {
  source                            = "../../../modules/tf-lambda-cloudwatch-event-trigger"
  cw-event-rule-name                = "${var.resend-confirmation-code-lambda-function-name}-warmer"
  cw-event-rule-description         = "${var.resend-confirmation-code-lambda-function-name} cloudwatch warmer"
  cw-event-rule-schedule-expression = "rate(10 minutes)"
  lambda-arn                        = aws_lambda_function.resend-confirmation-code-lambda.arn
  lambda-function-name              = aws_lambda_function.resend-confirmation-code-lambda.function_name
}

module "change-password-lambda-warmer" {
  source                            = "../../../modules/tf-lambda-cloudwatch-event-trigger"
  cw-event-rule-name                = "${var.change-password-lambda-function-name}-warmer"
  cw-event-rule-description         = "${var.change-password-lambda-function-name} cloudwatch warmer"
  cw-event-rule-schedule-expression = "rate(10 minutes)"
  lambda-arn                        = aws_lambda_function.change-password-lambda.arn
  lambda-function-name              = aws_lambda_function.change-password-lambda.function_name
}

module "create-user-lambda-warmer" {
  source                            = "../../../modules/tf-lambda-cloudwatch-event-trigger"
  cw-event-rule-name                = "${var.create-user-lambda-function-name}-warmer"
  cw-event-rule-description         = "${var.create-user-lambda-function-name} cloudwatch warmer"
  cw-event-rule-schedule-expression = "rate(10 minutes)"
  lambda-arn                        = aws_lambda_function.create-user-lambda.arn
  lambda-function-name              = aws_lambda_function.create-user-lambda.function_name
}

module "confirm-user-lambda-warmer" {
  source                            = "../../../modules/tf-lambda-cloudwatch-event-trigger"
  cw-event-rule-name                = "${var.confirm-user-lambda-function-name}-warmer"
  cw-event-rule-description         = "${var.confirm-user-lambda-function-name} cloudwatch warmer"
  cw-event-rule-schedule-expression = "rate(10 minutes)"
  lambda-arn                        = aws_lambda_function.confirm-user-lambda.arn
  lambda-function-name              = aws_lambda_function.confirm-user-lambda.function_name
}

module "confirm-mfa-lambda-warmer" {
  source                            = "../../../modules/tf-lambda-cloudwatch-event-trigger"
  cw-event-rule-name                = "${var.confirm-mfa-lambda-function-name}-warmer"
  cw-event-rule-description         = "${var.confirm-mfa-lambda-function-name} cloudwatch warmer"
  cw-event-rule-schedule-expression = "rate(10 minutes)"
  lambda-arn                        = aws_lambda_function.confirm-mfa-lambda.arn
  lambda-function-name              = aws_lambda_function.confirm-mfa-lambda.function_name
}

module "forgot-password-lambda-warmer" {
  source                            = "../../../modules/tf-lambda-cloudwatch-event-trigger"
  cw-event-rule-name                = "${var.forgot-password-lambda-function-name}-warmer"
  cw-event-rule-description         = "${var.forgot-password-lambda-function-name} cloudwatch warmer"
  cw-event-rule-schedule-expression = "rate(10 minutes)"
  lambda-arn                        = aws_lambda_function.forgot-password-lambda.arn
  lambda-function-name              = aws_lambda_function.forgot-password-lambda.function_name
}

module "reset-password-lambda-warmer" {
  source                            = "../../../modules/tf-lambda-cloudwatch-event-trigger"
  cw-event-rule-name                = "${var.reset-password-lambda-function-name}-warmer"
  cw-event-rule-description         = "${var.reset-password-lambda-function-name} cloudwatch warmer"
  cw-event-rule-schedule-expression = "rate(10 minutes)"
  lambda-arn                        = aws_lambda_function.reset-password-lambda.arn
  lambda-function-name              = aws_lambda_function.reset-password-lambda.function_name
}

module "confirm-password-lambda-warmer" {
  source                            = "../../../modules/tf-lambda-cloudwatch-event-trigger"
  cw-event-rule-name                = "${var.confirm-password-lambda-function-name}-warmer"
  cw-event-rule-description         = "${var.confirm-password-lambda-function-name} cloudwatch warmer"
  cw-event-rule-schedule-expression = "rate(10 minutes)"
  lambda-arn                        = aws_lambda_function.confirm-password-lambda.arn
  lambda-function-name              = aws_lambda_function.confirm-password-lambda.function_name
}

module "userinfo-lambda-warmer" {
  source                            = "../../../modules/tf-lambda-cloudwatch-event-trigger"
  cw-event-rule-name                = "${var.userinfo-lambda-function-name}-warmer"
  cw-event-rule-description         = "${var.userinfo-lambda-function-name} cloudwatch warmer"
  cw-event-rule-schedule-expression = "rate(10 minutes)"
  lambda-arn                        = aws_lambda_function.userinfo-lambda.arn
  lambda-function-name              = aws_lambda_function.userinfo-lambda.function_name
}

module "delete-user-lambda-warmer" {
  source                            = "../../../modules/tf-lambda-cloudwatch-event-trigger"
  cw-event-rule-name                = "${var.delete-user-lambda-function-name}-warmer"
  cw-event-rule-description         = "${var.delete-user-lambda-function-name} cloudwatch warmer"
  cw-event-rule-schedule-expression = "rate(10 minutes)"
  lambda-arn                        = aws_lambda_function.delete-user-lambda.arn
  lambda-function-name              = aws_lambda_function.delete-user-lambda.function_name
}
