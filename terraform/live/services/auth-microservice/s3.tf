module "auth-mfa" {
  source      = "../../../modules/tf-s3-encrypted"
  bucket-name = var.auth-mfa-bucket-name
}

resource "aws_s3_bucket_public_access_block" "auth-mfa-block-public-access" {
  bucket                  = module.auth-mfa.s3-id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

module "layers-packages" {
  source      = "../../../modules/tf-s3-encrypted"
  bucket-name = var.layers-packages-bucket-name
}

resource "aws_s3_bucket_public_access_block" "layers-packages-block-public-access" {
  bucket                  = module.layers-packages.s3-id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
