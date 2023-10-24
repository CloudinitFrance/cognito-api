variable "bucket-name" {
  description = "S3 bucket name"
}

variable "is-versioning-enabled" {
  description = "Enable or not objects versioning inside this bucket"
  default     = false
}
