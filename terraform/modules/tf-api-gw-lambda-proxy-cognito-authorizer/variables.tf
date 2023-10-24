variable "lambda-function-name" {
  description = "Lambda function name"
}

variable "lambda-function-arn" {
  description = "Lambda function arn"
}

variable "rest-api-id" {
  description = "Rest Api id"
}

variable "api-resource-id" {
  description = "Api resource Id"
}

variable "api-resource-path" {
  description = "Api resource Path"
}

variable "api-http-method" {
  description = "Api http method"
}

variable "is-api-key-required" {
  description = "Whether API KEY is required or not"
}

variable "cognito-authorizer-id" {
  description = "Cognito User Pool Id to use as an authorizer"
}

variable "authorization-scopes" {
	description = "Oauth2 Authorization Scopes"
	default = ["aws.cognito.signin.user.admin", "profile", "openid", "email", "phone"]
}
