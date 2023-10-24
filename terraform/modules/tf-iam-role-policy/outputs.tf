output "role-policy-id" {
  value = "${aws_iam_role_policy.iam-role-policy.id}"
}

output "role-policy-name" {
  value = "${aws_iam_role_policy.iam-role-policy.name}"
}

output "role-policy-policy-document" {
  value = "${aws_iam_role_policy.iam-role-policy.policy}"
}

output "role-policy-attached-role" {
  value = "${aws_iam_role_policy.iam-role-policy.role}"
}
