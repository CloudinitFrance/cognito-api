# Terraform AWS Encrypted S3 module

Create an encrypted s3 bucket  with the following:

- The s3 bucket is encrypted using AWS **AES256** server side encryption
- Objects versioning are disabled by default
- All put object against this bucket will be rejected unless objects are encrypted, cause we use this policy:

```json
{
    "Version": "2012-10-17",
    "Id": "PutObjPolicy",
    "Statement": [
        {
            "Sid": "DenyIncorrectEncryptionHeader",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::{BUCKET_NAME}/*",
            "Condition": {
                "StringNotEquals": {
                    "s3:x-amz-server-side-encryption": "AES256"
                }
            }
        },
        {
            "Sid": "DenyUnEncryptedObjectUploads",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::{BUCKET_NAME}/*",
            "Condition": {
                "Null": {
                    "s3:x-amz-server-side-encryption": "true"
                }
            }
        }
    ]
}
```

## Example:
```
module "bucket-sample" {
  source                             = "https://github.com/TarekCheikh/terraform-aws-modules//tf-s3-encrypted?ref=v1.0.0"
  bucket-name                        = "bucket-sample"
}
```

This will create an encrypted s3 bucket named **bucket-sample** 

## Terraform version

No special requirement, but as always try to use an up to date version:)

## Module outputs

This module exposes the following outputs:

- s3-id : The S3 bucket ID
- s3-arn: The S3 bucket ARN
