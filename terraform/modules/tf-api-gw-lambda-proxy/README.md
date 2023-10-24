# terraform tf-api-gw-lambda-proxy module

Terraform Api Gateway Lambda Proxy module

## Example:
```
module "change-password-lambda-endpoint" {
  source               = "https://github.com/TarekCheikh/terraform-aws-modules//tf-api-gw-lambda-proxy?ref=v1.0.0"
  rest-api-id          = "${aws_api_gateway_rest_api.api-gw.id}"
  api-resource-path    = "${aws_api_gateway_resource.change-password.path}"
  api-resource-id      = "${aws_api_gateway_resource.change-password.id}"
  api-http-method      = "POST"
  authorization-type   = "NONE"
  authorizer-id        = ""
  is-api-key-required  = "true"
  lambda-function-name = "${module.change-password-lambda.lambda-function-name}"
  lambda-function-arn  = "${module.change-password-lambda.lambda-function-arn}"
}
```
