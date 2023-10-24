output "user-pool-id" {
  value = aws_cognito_user_pool.user-pool.id
}

output "user-pool-arn" {
  value = aws_cognito_user_pool.user-pool.arn
}

output "user-pool-creation-date" {
  value = aws_cognito_user_pool.user-pool.creation_date
}

output "user-pool-last-modified-date" {
  value = aws_cognito_user_pool.user-pool.last_modified_date
}

output "user-pool-client-id" {
  value = aws_cognito_user_pool_client.user-pool-client.id
}
