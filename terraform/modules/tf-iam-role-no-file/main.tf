resource "aws_iam_role" "iam-role" {
  name               = "${var.iam-role-name}"
  path               = "${var.iam-role-path}"
  assume_role_policy = "${var.iam-assume-role-policy}"
}
