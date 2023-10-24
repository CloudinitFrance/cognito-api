variable "lambda-function-arn" {
  description = "Lambda function arn"
}

variable "lambda-function-name" {
  description = "Lambda function name"
}

variable "rest-api-id" {
  description = "Rest Api id"
}

variable "api-resource-id" {
  description = "Rest Api Resource Id"
}

variable "api-resource-path" {
  description = "Rest Api Resource Path"
}

variable "api-http-method" {
  description = "Api http method"
}

variable "authorization-type" {
  description = "Authorization type: NONE, CUSTOM, AWS_IAM, COGNITO_USER_POOLS"
}

variable "authorizer-id" {
  description = "Authorization Id to use (aws_api_gateway_authorizer)"
}

variable "is-api-key-required" {
  description = "Whether API KEY is required or not"
}
