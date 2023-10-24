resource "aws_iam_role_policy" "iam-role-policy" {
  name   = "${var.role-policy-name}"
  role   = "${var.role-name}"
  policy = "${file(var.role-policy-json-file)}"
}
