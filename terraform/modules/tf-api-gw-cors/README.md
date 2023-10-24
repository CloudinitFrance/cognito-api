# terraform tf-api-gw-cors module

Terraform Api Gateway Cors module

## Example:
```
module "users-list-cors" {
  source                            = "https://github.com/TarekCheikh/terraform-aws-modules//tf-api-gw-cors?ref=v1.0.0"
}
```

This will enable CORS for the **GET /users** endpoint by adding the following OPTIONS:
-
