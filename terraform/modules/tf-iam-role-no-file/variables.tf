variable "iam-role-name" {
  description = "The iam role name."
}

variable "iam-role-path" {
  description = "The path to the role."
  default     = "/"
}

variable "iam-assume-role-policy" {}
