# terraform tf-iam-role module

Terraform iam role module

## Example:
```
module "my-lambda-role" {
  source                            = "https://github.com/TarekCheikh/terraform-aws-modules//tf-iam-role?ref=v1.0.0"
  iam-role-name                     = "my-lambda-role"
  iam-role-path                     = "/"
  iam-assume-role-policy-file       = "./policies/lambda-assume-role-policy.json" 
}
```

This will create an aws iam role, with the following characteristics :
- Name **my-lambda-role**
- It has an assume role policy defined inside the file **./policies/lambda-assume-role-policy.json**
