variable "aws-region" {
  default = "eu-west-1"
}

variable "shared-credential-file" {
  default = "~/.aws/credentials"
}

variable "terraform-state-bucket" {}

variable "auth-microservice-terraform-state-file-key" {}

# ACM Certificate
variable "auth-api-acm-certificate-name" {}
variable "route53-zone-name" {}
variable "certificate-name-tag" {}

# Main API Dns Name
variable "auth-api-dns-name" {}

# API Gateway
variable "api-cloudwatch-log-group-name" {}
variable "apigw-account-settings-cloudwatch-role-name" {}
variable "apigw-account-settings-cloudwatch-policy-name" {}

variable "auth-api-name" {}
variable "auth-api-description" {}
variable "auth-api-r53-zone-id" {}
variable "auth-api-version" {}
variable "auth-api-stage-name" {}

# Cognito User Pool
variable "user-pool-name" {}

variable "password-minimum-length" {}
variable "password-require-lowercase" {}
variable "password-require-numbers" {}
variable "password-require-symbols" {}
variable "password-require-uppercase" {}
variable "mfa-configuration" {}
variable "user-pool-client-name" {}
variable "refresh-token-validity" {}
variable "cognito-sns-role-name" {}
variable "identity-pool-name" {}
variable "cognito-reply-to-email-address" {}
variable "cognito-from-email-address" {}
variable "cognito-ses-email-arn" {}
variable "new-user-email-message-template-file" {}

# Api Gateway Cognito Authorizer
variable "cognito-authorizer-name" {}

# Cognito Custom Message Trigger Lambda
variable "custom-message-lambda-function-name" {}
variable "custom-message-lambda-entrypoint" {}
variable "custom-message-lambda-function-desc" {}
variable "custom-message-lambda-memory-size" {}
variable "custom-message-lambda-runtime" {}
variable "custom-message-lambda-timeout" {}
variable "custom-message-lambda-zip-src-path" {}

# S3
variable "auth-mfa-bucket-name" {}
variable "layers-packages-bucket-name" {}

# Lambdas
variable "auth-lambdas-runtime" {}

variable "auth-lambdas-timeout" {}
variable "auth-lambdas-memory-size" {}

# Resend confirmation code
variable "resend-confirmation-code-lambda-function-name" {}

variable "resend-confirmation-code-lambda-function-desc" {}
variable "resend-confirmation-code-lambda-entrypoint" {}
variable "resend-confirmation-code-lambda-zip-src-path" {}

# Resend MFA
variable "resend-mfa-lambda-function-name" {}

variable "resend-mfa-lambda-function-desc" {}
variable "resend-mfa-lambda-entrypoint" {}
variable "resend-mfa-lambda-zip-src-path" {}
variable "users-mfa-folder" {}
variable "from-email" {}

# User first step authentication process
variable "user-login-lambda-function-name" {}

variable "user-login-lambda-function-desc" {}
variable "user-login-lambda-entrypoint" {}
variable "user-login-lambda-zip-src-path" {}

# User second step authentication process
variable "mfa-verify-lambda-function-name" {}

variable "mfa-verify-lambda-function-desc" {}
variable "mfa-verify-lambda-entrypoint" {}
variable "mfa-verify-lambda-zip-src-path" {}

# Refresh token
variable "refresh-token-lambda-function-name" {}

variable "refresh-token-lambda-function-desc" {}
variable "refresh-token-lambda-entrypoint" {}
variable "refresh-token-lambda-zip-src-path" {}

# User logout
variable "user-logout-lambda-function-name" {}

variable "user-logout-lambda-function-desc" {}
variable "user-logout-lambda-entrypoint" {}
variable "user-logout-lambda-zip-src-path" {}

# Create user
variable "create-user-lambda-function-name" {}

variable "create-user-lambda-function-desc" {}
variable "create-user-lambda-entrypoint" {}
variable "create-user-lambda-zip-src-path" {}

# Change password
variable "change-password-lambda-function-name" {}

variable "change-password-lambda-function-desc" {}
variable "change-password-lambda-entrypoint" {}
variable "change-password-lambda-zip-src-path" {}

# Reset password
variable "reset-password-lambda-function-name" {}

variable "reset-password-lambda-function-desc" {}
variable "reset-password-lambda-entrypoint" {}
variable "reset-password-lambda-zip-src-path" {}

# Forgot password
variable "forgot-password-lambda-function-name" {}

variable "forgot-password-lambda-function-desc" {}
variable "forgot-password-lambda-entrypoint" {}
variable "forgot-password-lambda-zip-src-path" {}

# Confirm password
variable "confirm-password-lambda-function-name" {}

variable "confirm-password-lambda-function-desc" {}
variable "confirm-password-lambda-entrypoint" {}
variable "confirm-password-lambda-zip-src-path" {}

# Confirm user
variable "confirm-user-lambda-function-name" {}

variable "confirm-user-lambda-function-desc" {}
variable "confirm-user-lambda-entrypoint" {}
variable "confirm-user-lambda-zip-src-path" {}

# Confirm mfa
variable "confirm-mfa-lambda-function-name" {}

variable "confirm-mfa-lambda-function-desc" {}
variable "confirm-mfa-lambda-entrypoint" {}
variable "confirm-mfa-lambda-zip-src-path" {}

# Userinfo
variable "userinfo-lambda-function-name" {}

variable "userinfo-lambda-function-desc" {}
variable "userinfo-lambda-entrypoint" {}
variable "userinfo-lambda-zip-src-path" {}

# Delete user
variable "delete-user-lambda-function-name" {}

variable "delete-user-lambda-function-desc" {}
variable "delete-user-lambda-entrypoint" {}
variable "delete-user-lambda-zip-src-path" {}
