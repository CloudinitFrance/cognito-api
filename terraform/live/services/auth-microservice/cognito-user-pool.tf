module "user-pool" {
  source                         = "../../../modules/tf-cognito-user-pool"
  user-pool-name                 = var.user-pool-name
  user-pool-client-name          = var.user-pool-client-name
  cognito-sns-role-arn           = module.sns-role.iam-role-arn
  mfa-configuration              = var.mfa-configuration
  custom-message-lambda-arn      = aws_lambda_function.custom-message-lambda.arn
  cognito-reply-to-email-address = var.cognito-reply-to-email-address
  cognito-from-email-address     = var.cognito-from-email-address
  cognito-ses-email-arn          = var.cognito-ses-email-arn
  new-user-email-message         = file(join("", ["${local.auth_microservice_path}/", var.new-user-email-message-template-file]))
}

data "template_file" "sns-assume-role-policy" {
  template = file("${local.auth_microservice_path}/policies/cognito-sns-assume-policy.json")
}

module "sns-role" {
  source                 = "../../../modules/tf-iam-role-no-file"
  iam-role-name          = var.cognito-sns-role-name
  iam-role-path          = "/"
  iam-assume-role-policy = data.template_file.sns-assume-role-policy.rendered
}

module "sns-role-policy" {
  source                = "../../../modules/tf-iam-role-policy"
  role-policy-name      = "${var.cognito-sns-role-name}-policy"
  role-policy-json-file = "${local.auth_microservice_path}/policies/cognito-sns-role-policy.json"
  role-name             = module.sns-role.iam-role-name
}

resource "aws_cognito_identity_pool" "user-pool-idp" {
  identity_pool_name               = var.identity-pool-name
  allow_unauthenticated_identities = false

  cognito_identity_providers {
    client_id               = module.user-pool.user-pool-client-id
    provider_name           = "cognito-idp.eu-west-1.amazonaws.com/${module.user-pool.user-pool-id}"
    server_side_token_check = true
  }
}

