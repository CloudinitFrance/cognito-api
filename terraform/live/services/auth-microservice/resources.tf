# /resend-mfa
resource "aws_api_gateway_resource" "resend-mfa" {
  rest_api_id = aws_api_gateway_rest_api.api-gw.id
  parent_id   = aws_api_gateway_rest_api.api-gw.root_resource_id
  path_part   = "resend-mfa"
}

# /resend-confirmation-code
resource "aws_api_gateway_resource" "resend-confirmation-code" {
  rest_api_id = aws_api_gateway_rest_api.api-gw.id
  parent_id   = aws_api_gateway_rest_api.api-gw.root_resource_id
  path_part   = "resend-confirmation-code"
}

# /login
resource "aws_api_gateway_resource" "login" {
  rest_api_id = aws_api_gateway_rest_api.api-gw.id
  parent_id   = aws_api_gateway_rest_api.api-gw.root_resource_id
  path_part   = "login"
}

# /logout
resource "aws_api_gateway_resource" "logout" {
  rest_api_id = aws_api_gateway_rest_api.api-gw.id
  parent_id   = aws_api_gateway_rest_api.api-gw.root_resource_id
  path_part   = "logout"
}

# /mfa-verify
resource "aws_api_gateway_resource" "mfa-verify" {
  rest_api_id = aws_api_gateway_rest_api.api-gw.id
  parent_id   = aws_api_gateway_rest_api.api-gw.root_resource_id
  path_part   = "mfa-verify"
}

# /refresh-token
resource "aws_api_gateway_resource" "refresh-token" {
  rest_api_id = aws_api_gateway_rest_api.api-gw.id
  parent_id   = aws_api_gateway_rest_api.api-gw.root_resource_id
  path_part   = "refresh-token"
}

# /userinfo
resource "aws_api_gateway_resource" "userinfo" {
  rest_api_id = aws_api_gateway_rest_api.api-gw.id
  parent_id   = aws_api_gateway_rest_api.api-gw.root_resource_id
  path_part   = "userinfo"
}

# /forgot-password
resource "aws_api_gateway_resource" "forgot-password" {
  rest_api_id = aws_api_gateway_rest_api.api-gw.id
  parent_id   = aws_api_gateway_rest_api.api-gw.root_resource_id
  path_part   = "forgot-password"
}


# /users
resource "aws_api_gateway_resource" "users" {
  rest_api_id = aws_api_gateway_rest_api.api-gw.id
  parent_id   = aws_api_gateway_rest_api.api-gw.root_resource_id
  path_part   = "users"
}

# /users/{user_id}
resource "aws_api_gateway_resource" "user-id" {
  rest_api_id = aws_api_gateway_rest_api.api-gw.id
  parent_id   = aws_api_gateway_resource.users.id
  path_part   = "{user_id}"
}

# /users/{user_id}/confirm
resource "aws_api_gateway_resource" "confirm" {
  rest_api_id = aws_api_gateway_rest_api.api-gw.id
  parent_id   = aws_api_gateway_resource.user-id.id
  path_part   = "confirm"
}

# /users/{user_id}/confirm-mfa
resource "aws_api_gateway_resource" "confirm-mfa" {
  rest_api_id = aws_api_gateway_rest_api.api-gw.id
  parent_id   = aws_api_gateway_resource.user-id.id
  path_part   = "confirm-mfa"
}

# /users/{user_id}/change-password
resource "aws_api_gateway_resource" "change-password" {
  rest_api_id = aws_api_gateway_rest_api.api-gw.id
  parent_id   = aws_api_gateway_resource.user-id.id
  path_part   = "change-password"
}

# /users/{user_id}/reset-password
resource "aws_api_gateway_resource" "reset-password" {
  rest_api_id = aws_api_gateway_rest_api.api-gw.id
  parent_id   = aws_api_gateway_resource.user-id.id
  path_part   = "reset-password"
}

# /users/{user_id}/confirm-password
resource "aws_api_gateway_resource" "confirm-password" {
  rest_api_id = aws_api_gateway_rest_api.api-gw.id
  parent_id   = aws_api_gateway_resource.user-id.id
  path_part   = "confirm-password"
}
