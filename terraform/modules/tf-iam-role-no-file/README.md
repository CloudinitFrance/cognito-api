# terraform tf-iam-role-no-file module

Terraform iam role module not provisionned by file

## Example:
```
module "my-role" {
  source                            = "https://github.com/TarekCheikh/terraform-aws-modules//tf-iam-role-no-file?ref=v1.0.0"
  iam-role-name                     = "my-role"
  iam-role-path                     = "/"
  iam-assume-role-policy-file       = "${data.aws_iam_policy_document.assume_role.json}"
}
```

This will create an aws iam role, with the following characteristics :
- Name **my-role**
- It has an assume role policy defined inside the iam_policy_document **assume_role**
