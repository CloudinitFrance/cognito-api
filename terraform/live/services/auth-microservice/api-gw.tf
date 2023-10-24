resource "aws_cloudwatch_log_group" "api-log-grp" {
  name = var.api-cloudwatch-log-group-name
}

resource "aws_iam_role" "apigw-account-settings-cloudwatch-role" {
  name = var.apigw-account-settings-cloudwatch-role-name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "apigw-account-settings-cloudwatch-role-policy" {
  name = var.apigw-account-settings-cloudwatch-policy-name
  role = aws_iam_role.apigw-account-settings-cloudwatch-role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents",
                "logs:GetLogEvents",
                "logs:FilterLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_api_gateway_account" "apigw-account-settings-cloudwatch" {
  cloudwatch_role_arn = aws_iam_role.apigw-account-settings-cloudwatch-role.arn
}

resource "aws_api_gateway_rest_api" "api-gw" {
  name        = var.auth-api-name
  description = var.auth-api-description

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_domain_name" "api-gw-dns" {
  domain_name = var.auth-api-dns-name

  regional_certificate_arn = aws_acm_certificate.cert.arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }
  depends_on = [aws_acm_certificate_validation.cert-validation]
}

resource "aws_api_gateway_deployment" "api-deployment" {
  rest_api_id = aws_api_gateway_rest_api.api-gw.id
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.login.id,
      module.user-login-lambda-endpoint.api-method-id,
      module.user-login-lambda-endpoint.lambda-integration-id,
      aws_api_gateway_resource.logout.id,
      module.user-logout-lambda-endpoint.api-method-id,
      module.user-logout-lambda-endpoint.lambda-integration-id,
      aws_api_gateway_resource.mfa-verify.id,
      module.mfa-verify-lambda-endpoint.api-method-id,
      module.mfa-verify-lambda-endpoint.lambda-integration-id,
      aws_api_gateway_resource.refresh-token.id,
      module.refresh-token-lambda-endpoint.api-method-id,
      module.refresh-token-lambda-endpoint.lambda-integration-id,
      aws_api_gateway_resource.resend-confirmation-code.id,
      module.resend-confirmation-code-lambda-endpoint.api-method-id,
      module.resend-confirmation-code-lambda-endpoint.lambda-integration-id,
      aws_api_gateway_resource.resend-mfa.id,
      module.resend-mfa-lambda-endpoint.api-method-id,
      module.resend-mfa-lambda-endpoint.lambda-integration-id,
      aws_api_gateway_resource.change-password.id,
      module.change-password-lambda-endpoint.api-method-id,
      module.change-password-lambda-endpoint.lambda-integration-id,
      aws_api_gateway_resource.users.id,
      aws_api_gateway_resource.confirm.id,
      module.confirm-user-lambda-endpoint.api-method-id,
      module.confirm-user-lambda-endpoint.lambda-integration-id,
      aws_api_gateway_resource.confirm-mfa.id,
      module.confirm-mfa-lambda-endpoint.api-method-id,
      module.confirm-mfa-lambda-endpoint.lambda-integration-id,
      aws_api_gateway_resource.reset-password.id,
      module.reset-password-lambda-endpoint.api-method-id,
      module.reset-password-lambda-endpoint.lambda-integration-id,
      aws_api_gateway_resource.forgot-password.id,
      module.forgot-password-lambda-endpoint.api-method-id,
      module.forgot-password-lambda-endpoint.lambda-integration-id,
      aws_api_gateway_resource.confirm-password.id,
      module.confirm-password-lambda-endpoint.api-method-id,
      module.confirm-password-lambda-endpoint.lambda-integration-id,
      aws_api_gateway_resource.userinfo.id,
      module.userinfo-lambda-endpoint.api-method-id,
      module.userinfo-lambda-endpoint.lambda-integration-id,
      aws_api_gateway_resource.user-id.id,
    ]))
  }

  depends_on = [
    module.user-login-lambda-endpoint,
    module.user-logout-lambda-endpoint,
    module.mfa-verify-lambda-endpoint,
    module.refresh-token-lambda-endpoint,
    module.resend-confirmation-code-lambda-endpoint,
    module.resend-mfa-lambda-endpoint,
    module.change-password-lambda-endpoint,
    module.confirm-user-lambda-endpoint,
    module.confirm-mfa-lambda-endpoint,
    module.reset-password-lambda-endpoint,
    module.forgot-password-lambda-endpoint,
    module.confirm-password-lambda-endpoint,
    module.userinfo-lambda-endpoint,
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "api-stage" {
  deployment_id = aws_api_gateway_deployment.api-deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api-gw.id
  stage_name    = var.auth-api-stage-name
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api-log-grp.arn
    format          = replace(file("${path.module}/logformat.json"), "\n", "")
  }
  depends_on = [aws_cloudwatch_log_group.api-log-grp]
}

resource "aws_api_gateway_method_settings" "api-settings" {
  rest_api_id = aws_api_gateway_rest_api.api-gw.id
  stage_name  = aws_api_gateway_stage.api-stage.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = true
    logging_level   = "INFO"
  }
}

resource "aws_api_gateway_base_path_mapping" "api-v1-mapping" {
  api_id      = aws_api_gateway_rest_api.api-gw.id
  stage_name  = aws_api_gateway_stage.api-stage.stage_name
  domain_name = aws_api_gateway_domain_name.api-gw-dns.domain_name
  base_path   = var.auth-api-version
}
