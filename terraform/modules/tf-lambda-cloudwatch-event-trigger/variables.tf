variable "cw-event-rule-name" {
  description = "Cloudwatch event rule name"
}

variable "cw-event-rule-description" {
  description = "Cloudwatch event rule description"
}

variable "cw-event-rule-schedule-expression" {
  description = "Cloudwatch event rule schedule expression"
}

variable "lambda-arn" {
  description = "Target lambda arn"
}

variable "lambda-function-name" {
  description = "Target lambda function name"
}
