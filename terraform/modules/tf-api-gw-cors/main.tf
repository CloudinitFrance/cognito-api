locals {
  methodOptions  = "OPTIONS"
  #defaultHeaders = ["Content-Type", "X-Amz-Date", "Authorization", "X-Api-Key", "X-Amz-Security-Token"]
  defaultHeaders = ["Content-Type", "X-Amz-Date", "X-Amz-Security-Token", "Authorization", "X-Api-Key", "X-Requested-With", "Accept", "Access-Control-Allow-Methods", "Access-Control-Allow-Origin", "Access-Control-Allow-Headers"]
  #methods = "${join(",", concat(var.api-http-methods, tolist(local.methodOptions)))}"
  methods = "'${join(",", var.api-http-methods)}'"
  headers = "${var.discard-default-headers ? join(",", var.headers) : join(",", distinct(concat(var.headers, local.defaultHeaders)))}"
}

resource "aws_api_gateway_method" "cors-method" {
  rest_api_id = "${var.rest-api-id}"
  resource_id = "${var.api-resource-id}"
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "cors-integration" {
  rest_api_id = "${var.rest-api-id}"
  resource_id = "${var.api-resource-id}"
  http_method = "${aws_api_gateway_method.cors-method.http_method}"
  type        = "MOCK"

  request_templates = {
    "application/json" = <<EOF
{ "statusCode": 200 }
EOF
  }
}

resource "aws_api_gateway_method_response" "cors-method-response" {
  rest_api_id = "${var.rest-api-id}"
  resource_id = "${var.api-resource-id}"
  http_method = "${aws_api_gateway_method.cors-method.http_method}"

  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "cors_integration_response" {
  rest_api_id = "${var.rest-api-id}"
  resource_id = "${var.api-resource-id}"
  http_method = "${aws_api_gateway_method.cors-method.http_method}"
  status_code = "${aws_api_gateway_method_response.cors-method-response.status_code}"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'${local.headers}'"
    "method.response.header.Access-Control-Allow-Methods" = "'${local.methods}'"
    "method.response.header.Access-Control-Allow-Origin"  = "'${var.origin}'"
  }
}
