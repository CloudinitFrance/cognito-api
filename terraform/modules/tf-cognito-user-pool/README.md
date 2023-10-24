# Terraform AWS Cognito User Pool module

Create an AWS Cognito User Pool with the following:


## Example:
```
module "api-user-pool" {
  source                   = "https://github.com/TarekCheikh/terraform-aws-modules//tf-cognito-user-pool?ref=v1.0.0"
}
```

This will create an AWS cognito user pool , with the following characteristics :
- Named **vpc-test**

## Terraform version

[0.10.3](https://github.com/hashicorp/terraform/pull/15449) This module uses Terraform **Local Values** introduced with version **0.10.3**

## Module outputs

This module exposes the following outputs:

