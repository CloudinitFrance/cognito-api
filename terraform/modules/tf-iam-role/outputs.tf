output "iam-role-arn" {
  value = "${aws_iam_role.iam-role.arn}"
}

output "iam-role-name" {
  value = "${aws_iam_role.iam-role.name}"
}

output "iam-role-unique-id" {
  value = "${aws_iam_role.iam-role.unique_id}"
}
