variable "user-pool-name" {
  description = "AWS Cognito user pool name"
}

variable "password-minimum-length" {
  description = "Password minimum length"
  default     = "14"
}

variable "password-require-lowercase" {
  description = "If password require lower case"
  default     = true
}

variable "password-require-numbers" {
  description = "If password require numbers"
  default     = true
}

variable "password-require-symbols" {
  description = "If password require symbols"
  default     = true
}

variable "password-require-uppercase" {
  description = "If password require upper case"
  default     = true
}

variable "mfa-configuration" {
  description = "Set to enable multi-factor authentication. Must be one of the following values (ON, OFF, OPTIONAL)"
  default     = "OPTIONAL"
}

variable "user-pool-client-name" {
  description = "The name of the application client"
}

variable "cognito-sns-role-arn" {
  description = "The ARN role for SNS"
}

variable "generate-app-client-secret" {
  description = "Generate App Client Secret or not"
  default     = false
}

variable "id-token-validity" {
  description = "Time limit, between 5 minutes and 1 day, after which the ID token is no longer valid and cannot be used"
  default     = 1
}

variable "access-token-validity" {
  description = "Time limit, between 5 minutes and 1 day, after which the ACCESS token is no longer valid and cannot be used"
  default     = 1
}

variable "refresh-token-validity" {
  description = "Time limit in days refresh tokens are valid for"
  default     = 1
}

variable "enable-token-revocation" {
  description = "Enables or disables token revocation"
  default     = true
}


variable "custom-message-lambda-arn" {
  description = "The custom message lambda arn"
}

variable "cognito-reply-to-email-address" {
  description = "The email address to use as reply to"
}

variable "cognito-from-email-address" {
  description = "The email address to use as sender"
}

variable "cognito-ses-email-arn" {
  description = "The SES email address ARN"
}

variable "new-user-email-message" {
  description = "The new user welcome email message"
}
