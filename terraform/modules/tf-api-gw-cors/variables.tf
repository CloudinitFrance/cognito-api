variable "rest-api-id" {
  description = "Rest Api id"
}

variable "api-resource-id" {
  description = "Rest Api Resource Id"
}

variable "api-http-methods" {
  description = "Api http method"
  type = list(string)
}

variable "origin" {
  description = "Permitted origin"
  default     = "*"
}

variable "headers" {
  description = "List of permitted headers. Default headers are always present unless discard-default-headers variable is set to true"
  default     = ["Content-Type", "X-Amz-Date", "Authorization", "X-Api-Key", "X-Amz-Security-Token"]
}

variable "discard-default-headers" {
  default     = false
  description = "When set to true to it discards the default permitted headers and only includes those explicitly defined"
}
