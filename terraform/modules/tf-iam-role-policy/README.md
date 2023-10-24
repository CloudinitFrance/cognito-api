# terraform iam role policy

Terraform iam role policy module

## Example:
```
module "my-role-policy" {
  source                   = "https://github.com/TarekCheikh/terraform-aws-modules//tf-iam-role-policy?ref=v1.0.0"
  role-policy-name         = "my-role-policy"
  role-policy-json-file    = "./policies/my-role-policy.json"
  role-name                = "my-role"
}
```

This will create an iam role policy, with the following characteristics :
- Name **my-role-policy**
- Using permissions defined here **./policies/my-role-policy.json**
- Attached to the role : **my-role**
