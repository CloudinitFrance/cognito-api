resource "aws_cognito_user_pool" "user-pool" {
  name = var.user-pool-name

  admin_create_user_config {
    allow_admin_create_user_only = true

    invite_message_template {
      email_subject = "Welcome to CognitoApi"
      email_message = var.new-user-email-message
      sms_message   = "Your username is {username} and temporary password is {####}. "
    }
  }

  username_attributes = ["email"]

  schema {
    attribute_data_type      = "String"
    mutable                  = true
    name                     = "name"
    required                 = true
    developer_only_attribute = false
    string_attribute_constraints {
      max_length = "2048"
      min_length = "0"
    }
  }
  schema {
    attribute_data_type      = "String"
    mutable                  = true
    name                     = "email"
    required                 = true
    developer_only_attribute = false
    string_attribute_constraints {
      max_length = "2048"
      min_length = "0"
    }
  }
  schema {
    attribute_data_type      = "String"
    mutable                  = true
    name                     = "phone_number"
    required                 = true
    developer_only_attribute = false
    string_attribute_constraints {
      max_length = "2048"
      min_length = "0"
    }
  }

  password_policy {
    minimum_length                   = var.password-minimum-length
    require_lowercase                = var.password-require-lowercase
    require_numbers                  = var.password-require-numbers
    require_symbols                  = var.password-require-symbols
    require_uppercase                = var.password-require-uppercase
    temporary_password_validity_days = 1
  }

  mfa_configuration = var.mfa-configuration

  auto_verified_attributes = ["email"]

  #sms_configuration {
  #  external_id    = "sns_external_id"
  #  sns_caller_arn = "${var.cognito-sns-role-arn}"
  #}

  software_token_mfa_configuration {
    enabled = true
  }

  account_recovery_setting {

    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }

    recovery_mechanism {
      name     = "verified_phone_number"
      priority = 2
    }
  }

  lambda_config {
    custom_message = var.custom-message-lambda-arn
  }
  email_configuration {
    email_sending_account  = "DEVELOPER"
    reply_to_email_address = var.cognito-reply-to-email-address
    from_email_address     = var.cognito-from-email-address
    source_arn             = var.cognito-ses-email-arn
  }
}

resource "aws_cognito_user_pool_client" "user-pool-client" {
  name = var.user-pool-client-name

  user_pool_id            = aws_cognito_user_pool.user-pool.id
  generate_secret         = var.generate-app-client-secret
  explicit_auth_flows     = ["ADMIN_NO_SRP_AUTH"]
  id_token_validity       = var.id-token-validity
  access_token_validity   = var.access-token-validity
  refresh_token_validity  = var.refresh-token-validity
  enable_token_revocation = var.enable-token-revocation
}
