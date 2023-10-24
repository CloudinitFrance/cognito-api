resource "aws_lambda_layer_version" "jsonschema" {
  filename   = "${local.auth_microservice_path}/layers-src/jsonschema/jsonschema.zip"
  layer_name = "jsonschema"

  compatible_runtimes      = [var.auth-lambdas-runtime]
  compatible_architectures = ["x86_64"]
}

resource "aws_lambda_layer_version" "pyjwt" {
  filename   = "${local.auth_microservice_path}/layers-src/pyjwt/pyjwt.zip"
  layer_name = "pyjwt"

  compatible_runtimes      = [var.auth-lambdas-runtime]
  compatible_architectures = ["x86_64"]
}

resource "aws_lambda_layer_version" "pillow" {
  filename   = "${local.auth_microservice_path}/layers-src/pillow/pillow.zip"
  layer_name = "pillow"

  compatible_runtimes      = [var.auth-lambdas-runtime]
  compatible_architectures = ["x86_64"]
}

resource "aws_lambda_layer_version" "pyotp" {
  filename   = "${local.auth_microservice_path}/layers-src/pyotp/pyotp.zip"
  layer_name = "pyotp"

  compatible_runtimes      = [var.auth-lambdas-runtime]
  compatible_architectures = ["x86_64"]
}

resource "aws_lambda_layer_version" "qrcode" {
  filename   = "${local.auth_microservice_path}/layers-src/qrcode/qrcode.zip"
  layer_name = "qrcode"

  compatible_runtimes      = [var.auth-lambdas-runtime]
  compatible_architectures = ["x86_64"]
}

# OpenCV headless is too large
resource "aws_s3_object" "opencv-zip" {
  bucket                 = var.layers-packages-bucket-name
  key                    = "layers/opencv.zip"
  source                 = "${local.auth_microservice_path}/layers-src/opencv/opencv.zip"
  server_side_encryption = "AES256"
  depends_on             = [module.layers-packages.s3-id]
}

resource "aws_lambda_layer_version" "opencv" {
  s3_bucket  = var.layers-packages-bucket-name
  s3_key     = aws_s3_object.opencv-zip.key
  layer_name = "opencv"

  compatible_runtimes      = [var.auth-lambdas-runtime]
  compatible_architectures = ["x86_64"]
}
