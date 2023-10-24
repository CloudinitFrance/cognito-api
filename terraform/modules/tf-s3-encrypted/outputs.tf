output "s3-id" {
  value = "${aws_s3_bucket.s3.id}"
}

output "s3-arn" {
  value = "${aws_s3_bucket.s3.arn}"
}
