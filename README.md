# CognitoApi 🔐

[![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://www.python.org/)
[![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white)](https://aws.amazon.com/)
[![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

CognitoApi is an authentication and user management api based on the solid AWS Cognito service. It will let's you build your applications without thinking about the authentication part.

A detailed documentation and a dedicated website about this project with a lot of material is located here: [CognitoApi](https://cognito-api.com).

## Key Features ✨

- 🛡️ **Security**: The solution is very secure and uses MFA (Multi Factor Authentication) which adds an important security layer to your apps.

- ☁️ **AWS Cognito as a backend**: The CognitoApi is based at it's heart on the [AWS Cognito service](https://docs.aws.amazon.com/cognito/), known to be very secure and cost efffective.

- 💰 **Cost**: AWS Cognito is free of the first 50K users (or MAU: Monthly Active Users), so it's a good choice for bootstraping your app without thinking about the cost.

- 👥 **User Managment Lifecycle**: The solution supports the needed users management life cycle from the creation till the deletion.

- 🤖 **Fully automated**: Nothing to do except deploying using Terraform.

- 🌐 **Cors support**: The Cors is already supported, you can plug your front without any effort.

## Pre-requisites 📋

Before installing the CognitoApi, please ensure that you already installed:

- 🏗️ [Terraform](https://www.terraform.io/): a recent version is recommeneded, in order to deploy all the underlaying AWS infrastructure.

- 🐳 [Docker](https://www.docker.com/): to build all lambdas and their layers in an automatic way.

- 🔧 [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html): to perform some of the project bootstraping actions like creating the S3 bucket and DynamoDB table for Terraform states and collaboration.


## Installation 📥

> **Warning**
First you need to configure at least one deployment environement, let's call it dev, by filling the corresponding configuration file **terraform/environments/dev/terraform.tfvars.dev**

And here is the explanation of the relevant parameters:

| Parameter | Description | Example |
|-----------|-------------|---------|
| aws-region | The region where to deploy your authentication API | eu-west-1 |
| terraform-state-bucket | This S3 bucket will hold your terraform states files | my-tf-state-bucket |
| auth-api-dns-name | This is the dns to use for your API | auth.dev.thecadors.com |
| auth-api-acm-certificate-name | This is the domain name for which the certificate should be issued | *.dev.thecadors.com |
| route53-zone-name | The route 53 zone id that will be used for the domain name of your API | dev.thecadors.com |
| certificate-name-tag | The tag name that will be set for the ACM certificate used by your API | wildcard.dev.thecadors.com |
| auth-api-name | The authentication API name | thecadors-auth-api |
| auth-api-description | The authentication API description | TheCadors Auth API |
| auth-api-r53-zone-id | The route53 zone ID to use (corresponding to **route53-zone-name**) | Z1029992156D8O |
| auth-api-stage-name | The API gateway stage name to use | development |
| auth-mfa-bucket-name | The S3 bucket used to store MFAs QrCodes | cadors-auth-api-users-mfa-dev |
| cognito-reply-to-email-address | The email that will be used when a user want to answer your emails | hello@myapp.io |
| cognito-from-email-address | The email that will be used to send emails by AWS Cognito | hello@myapp.io |
| cognito-ses-email-arn | The ARN of the SES verified email identity to use | arn:aws:ses:eu-west-1:012345678901:identity/hello@myapp.io |
| from-email | This will be used by the CognitoApi to resend for you your MFA Qrcode | hello@myapp.io |
| layers-packages-bucket-name | The name of the S3 bucket where to upload the lambdas layers ZIPs | my-lambda-layers-bucket |

The process of installation is as follow:

```command
export AWS_PROFILE=MyAwsDevProfile
git clone https://github.com/CloudinitFrance/cognito-api.git
cd terraform
ENVIRONMENT=dev make test
ENVIRONMENT=dev make plan
ENVIRONMENT=dev make apply
```

The last commands will:

- Set up your AWS porfile by exporting it inside the terminal, please change the name of the profile **MyAwsDevProfile** to yours and set it also inside the file **terraform/live/services/auth-microservice/provider.tf**.

- Test the terfform infrastructure files.

- Perform a **terraform plan** to check if everything is okay and gives you an idea about all resources that will be deployed.

- Perform a **terraform apply** to deploy all the needed infrastructure inside your AWS account.

Please refer to the Makefile help: ![Mkaefile help](https://github.com/CloudinitFrance/cognito-api/blob/main/assets/00-Make-Help.png?raw=true)

## Architecture 🏛️

The deployed infrastructure looks like this:

![CognitoApi](https://github.com/CloudinitFrance/cognito-api/blob/main/assets/CognitoApi.jpg?raw=true)


## Deployed resources 🚀

| Resource Type | Count | Purpose |
|---------------|-------|---------|
| API Gateway | 1 | To expose the authentication Rest API |
| Cognito User Pool | 1 | To hold all the users and manage their lifecycle |
| Lambdas | 16 | For the authentication API backend handling |
| Lambdas layers | 6 | Shared code for lambdas |
| S3 buckets | 2 | For terraform infrastructure and MFA storing |
| DynamoDB table | 1 | For terraform infrastructure collaboration lock |
| ACM Certificate | 1 | For the Rest API |
| Route53 records | 2 | For the ACM verification and the API custom domain |


## Cost estimation 💵

It's hard, because it depends on the context of everyone, but let's use the these parameters:

- 🌍 The deployment region is **eu-west-1**.

- 👥 Let's assume **50K users** and all of them perform a login (2 requests) everyday on the app (the RefreshToken is valid for 24 hours, so the app can use it to refresh the user session), that's mean 24 requests, so in total: 26 requests per user per day, which means: 1.3 millions requests for maintaing sessions on a daily basis. This also means that users are connected 24 hours per day all time (very unlikly to heppen).

- 🧮 Let's assume that all backend lambdas uses **256MB** of memory and for each call the average duration of each lambda is 1 second (which is excessive!). They will be called 1.3 million every day.

Based on all these assumptions, the authentication and the user management of your application for 50k users will costs you around: [150$ per month](https://calculator.aws/#/estimate?id=892669bfa775354618815f79032e31970f88915c), this means **0.003$** per user and per month! Hard to find on the market a serious competitor at this level.


## Implementation notes 📝

We did a lot of technical choices inside this project:

- 🏗️ The use of Terraform as the main IAC (Infrastructure As Code) is absolutely innocent :). The main reason of this choice instead of Cloudformation or any other IAC tool is the popularity and the simplicity. I've been using personally Tarreform from almost the first release and i've been (in general quiet satisfied about it).

- 🔐 MFAs are mandatory and i've choosed to activate the **Google Authenticator MFA** by default, mainly because ther's no additional costs.

- 📱 AWS Cognito does not allow a direct and esay way to recover users MFAs, so to add the ability for the end user to restore them MFAs, the solution save the QrCodes inside an encrypted and secure S3 bucket. This solution can be not acceptable for some of you and i can understand it, in this case don't use it, i have an alternative involvingthe set of an SMS as a secondary MFA. Track this feature on the next releases. 

- 📋 The **CognitoApi** is using a Makefile to pilot all the infrastructure deployment, this Makfile is designed to handle multi environement deployment, to do so just create a configuration environement file named: **environments/MyEnvName/terraform.tfvars.MyEnvName**. If you want to handle the multi environements using Terraform workspaces, please share your version with us.

- 🔑 The implementation is using an API Key just to protect against unwanted access in a testing phase, this is not a valid protection, the best way to do it in the case of a WebApp is to use a proxy for your frontend in order to hide your API Key. Remember that everything that you load inside the enduser browser can be seen and inspected very easily.

- 🔒 Password policy is: 14 characters minimum length that contains at least 1 number, at least 1 special character, at least 1 uppercase letter and at least 1 lowercase letter.

- 🛡️ Due to the cost of AWS WAF service i didn't integrate it with this solution, but i highly recommened you to use it in a production environement to protect your API against illegitimate traffic.

- ⏱️ Access and ID Tokens are set to be valide for one hour, the Refresh Token is valid for 24 hours. If you want to modify these values, just set the target values for: **id-token-validity**, **access-token-validity** and **refresh-token-validity** variables.

- 🔍 The **Advanced security features** of Cognito are disabled because of tehir cost.


## API Documentation 📚

> **Warning**
All endpoints needs the header: x-api-key which must be set by generating an API Key inside your AWS Api Gateway and associate it with your deployment stage and a usage plan.

You can find a Postman collection here: **postman/CognitoApi.postman_collection.json**. You need to set the following variables inside Postman:

| Variable | Description |
|----------|-------------|
| API_BASE_URL | which is the dns name to use to call your auth api |
| API_KEY | should be the one that you will generate for your tests inside the API Gateway |
| EMAIL | the email of the user you want to create |
| PASSWORD | the password to use when you create a test user |
| VerificationType | must be set to **SOFTWARE_TOKEN_MFA** |

The TOTP inside Postman is generated for you automatically using the **MFA_SECRET** environement variable, which is set from the API call output, once the user has been confirmed.

Let's see how this API works:

### User Management Lifecycle 👥

- **Create a new user**: Use a **POST** method on the endpoint: **v1/users** with the payload:

```json
{
    "full_name": "Tarek CHEIKH",
    "email": "tarek@cloudinit.fr",
    "mobile_phone_number": "+3301234567"
}
```

And you will get an answer that looks like this:

```json
{
    "email": "tarek@cloudinit.fr",
    "user_id": "129514d4-b081-7004-e470-b6adacd32db4",
    "status": "CREATED"
}
```

After this call the new user will receive an email containing a temporary password, that he need to use with the endpoint: **v1/users/{{USER_ID}}/confirm** to confirm the creation.

![Create User API Call](https://github.com/CloudinitFrance/cognito-api/blob/main/assets/01-CreateUser.png?raw=true)
![Create User Email](https://github.com/CloudinitFrance/cognito-api/blob/main/assets/02-CreateUser-Email.png?raw=true)

- **Confirm a new user**: Use a **POST** method on the endpoint: **v1/users/{{USER_ID}}/confirm** with the payload:

```json
{
    "email": "tarek@cloudinit.fr",
    "temporary_password": "WpbyHbcIc#pNo3",
    "new_password": "WpbyHbcIc#pNp9"
}
```

And you will get an answer that looks like this:

```json
{
    "email": "tarek@cloudinit.fr",
    "user_id": "129514d4-b081-7004-e470-b6adacd32db4",
    "qr_code_secret": "UB42J65BKO473DIOOXGWOQZYT7AZKAS7W3AAHVTVT5IPRV",
    "qr_code_secret_url": "https://cloudinit-auth-api-users-mfa-dev.s3.amazonaws.com/users_mfa/129514d4-b081-7004-e470-b6adacd32db4.png?AWSAccessKeyId=ASIA6G4XIYTL3SKD6LTU&Signature=WE0Kq6BzB%2FMvyf1IZt8Dq",
    "status": "ACTIVE"
}
```

![Confirm New User API Call](https://github.com/CloudinitFrance/cognito-api/blob/main/assets/03-ConfirmNewUser.png?raw=true)

- **Confirm the MFA**: Use a **POST** method on the endpoint: **v1/users/{{USER_ID}}/confirm-mfa** with the payload:

```json
{
    "email": "{{EMAIL}}",
    "otp": "123456"
}
```

And you will get an answer that looks like this:

```json
{
    "email": "tarek@cloudinit.fr",
    "user_id": "129514d4-b081-7004-e470-b6adacd32db4",
    "mfa_status": "CONFIRMED"
}
```

![Confirm The New MFA API Call](https://github.com/CloudinitFrance/cognito-api/blob/main/assets/04-ConfirmMFA.png?raw=true)

- **For a forgotten password**: Use a **POST** method on the endpoint: **v1/forgot-password** with the payload: 

```json
{
    "email": "tarek@cloudinit.fr"
}
```

And you will get an answer that looks like this:

```json
{
    "email": "tarek@cloudinit.fr",
    "user_id": "129514d4-b081-7004-e470-b6adacd32db4",
    "status": "PASSWORD_FORGOT_CONFIRMATION_SENT"
}
```

![Forgot Password API Call](https://github.com/CloudinitFrance/cognito-api/blob/main/assets/05-ForgotPassword.png?raw=true)
![Forgot Password Email](https://github.com/CloudinitFrance/cognito-api/blob/main/assets/06-ForgotPassword-Email.png?raw=true)

- **To set a forgotten password**: Use a **POST** method on the endpoint: **/v1/users/{{USER_ID}}/confirm-password** with the payload: 

```json
{
    "email": "tarek@cloudinit.fr",
    "new_password": "#Y3KdGR9QKg_a9",
    "verification_code": "304482"
}
```

And you will get an answer that looks like this:

```json
{
    "email": "tarek@cloudinit.fr",
    "user_id": "129514d4-b081-7004-e470-b6adacd32db4",
    "status": "NEW_PASSWORD_SET_SUCCESSFULLY"
}
```

![Set Forgotten Password API Call](https://github.com/CloudinitFrance/cognito-api/blob/main/assets/07-SetForgottenPassword.png?raw=true)

### User Authentication 🔐

- **Perform the first step of the login process**: Use a **POST** method on the endpoint: **v1/login** with the payload:

```json
{
    "email": "tarek@cloudinit.fr",
    "password": "WpbyHbcIc#pNp9"
}
```

And you will get an answer that looks like this:

```json
{
    "email": "tarek@cloudinit.fr",
    "verification_session": "AYABeLHXhcXCnAA3E29UUMbVqKgAHQABAAdTZXJ2aWNlABBDb2duaXRvVXNlclBvb2xz",
    "verification_type": "SOFTWARE_TOKEN_MFA"
}
```

![1st step of the login API Call](https://github.com/CloudinitFrance/cognito-api/blob/main/assets/08-UserLogin.png?raw=true)

After this call, the user needs to perform the MFA verification step using the verification session.

- **Perform the second step of the login process (MFA challenge)**: Use a **POST** method on the endpoint: **v1/mfa-verify** with the payload:

```json
{
    "email": "129514d4-b081-7004-e470-b6adacd32db4",
    "verification_type": "SOFTWARE_TOKEN_MFA",
    "verification_session": "AYABeLHXhcXCnAA3E29UUMbVqKgAHQABAAdTZXJ2aWNlABBDb2duaXRvVXNlclBvb2xz",
    "otp_code": "012345"
}
```

And you will get an answer that looks like this:

```json
{
    "id_token": "eyJraWQiOiJpK0dwZFZLVUY1eG1ESml6Ukk2YTVWYTV6ZEtyXC8zeElyR",
    "access_token": "eyJraWQiOiJudUFPSENpcStPZnk3enF5TjFBZERSSEpQcUtZS1EwS",
    "refresh_token": "eyJjdHkiOiJKV1QiLCJlbmMiOiJBMjU2R0NNIiwiYWxnIjoiUlNB",
    "expires_in": 3600
}
```

![MFA step of the login API Call](https://github.com/CloudinitFrance/cognito-api/blob/main/assets/09-MfaVerify.png?raw=true)

At this moment, the user has been logged successfully.

- **To get new tokens using your RefreshToken**: Use a **POST** method on the endpoint: **v1/refresh-token** with the payload:

```json
{
    "email": "tarek@cloudinit.fr",
    "refresh_token": "eyJjdHkiOiJKV1QiLCJlbmMiOiJBMjU2R0NNIiwiYWxnIjoiUlNBLU9BRVAifQ."
}
```

And you will get an answer that looks like this:

```json
{
    "email": "tarek@cloudinit.fr",
    "id_token": "eyJraWQiOiJpK0dwZFZLVUY1eG1ESml6Ukk2YTVWYTV6ZEtyXC8zeElyR2owZk",
    "access_token": "eyJraWQiOiJudUFPSENpcStPZnk3enF5TjFBZERSSEpQcUtZS1EwSU9mUGd",
    "refresh_token": "eyJjdHkiOiJKV1QiLCJlbmMiOiJBMjU2R0NNIiwiYWxnIjoiUlNBLU9BRVA",
    "expires_in": 3600
}
```

![RefreshToken API Call](https://github.com/CloudinitFrance/cognito-api/blob/main/assets/10-RefreshToken.png?raw=true)

- **To get informations about the connected user**: Use a **GET** method on the endpoint: **v1/userinfo** and you will get an answer that looks like this:

```json
{
    "user_id": "129514d4-b081-7004-e470-b6adacd32db4",
    "email": "tarek@cloudinit.fr",
    "groups": [],
    "given_name": "Tarek",
    "family_name": "CHEIKH"
}
```

![Userinfo API Call](https://github.com/CloudinitFrance/cognito-api/blob/main/assets/11-Userinfo.png?raw=true)

- **To logout**: Use a **POST** method on the endpoint: **v1/logout** with the payload:

```json
{
    "email": "tarek@cloudinit.fr",
    "access_token": "eyJjdHkiOiJKV1QiLCJlbmMiOiJBMjU2R0NNIiwiYWxnIjoi"
}
```

And you will get an answer that looks like this:

```json
{
    "user_status": "logout"
}
```

![Logout API Call](https://github.com/CloudinitFrance/cognito-api/blob/main/assets/12-User-Logout.png?raw=true)

## API Endpoints Summary 📋

| Endpoint | Method | Purpose | 
|----------|--------|---------|
| v1/users | POST | Create a new user |
| v1/users/{USER_ID}/confirm | POST | Confirm a new user |
| v1/users/{USER_ID}/confirm-mfa | POST | Confirm MFA setup |
| v1/forgot-password | POST | Initiate password reset process |
| v1/users/{USER_ID}/confirm-password | POST | Complete password reset |
| v1/login | POST | Initial login step |
| v1/mfa-verify | POST | Complete MFA verification |
| v1/refresh-token | POST | Get new tokens using refresh token |
| v1/userinfo | GET | Get authenticated user information |
| v1/logout | POST | Log out a user |

## Demo Application 🚀

Want to see CognitoApi in action? Check out our integration example with a React frontend:

[![React Demo App](https://img.shields.io/badge/React_Demo-61DAFB?style=for-the-badge&logo=react&logoColor=black)](https://github.com/CloudinitFrance/cognito-api-react-example-app)

This example app demonstrates:

- 🔑 Complete authentication flow integration
- 🔄 Token refresh handling
- 👤 User registration and confirmation process
- 🔒 MFA implementation
- 💼 Session management

The demo application is a great starting point to understand how to integrate CognitoApi with your frontend and provides a practical reference for implementation.

```bash
# Clone the demo app
git clone https://github.com/CloudinitFrance/cognito-api-react-example-app.git

# Follow the setup instructions in the repo's README
```

## Supported Regions 🌎

The solution is designed to work in any AWS region where Cognito is available:

| Region Flag | Region Name | Region Code |
|-------------|-------------|-------------|
| 🇺🇸 | US East (N. Virginia) | us-east-1 |
| 🇺🇸 | US East (Ohio) | us-east-2 |
| 🇺🇸 | US West (N. California) | us-west-1 |
| 🇺🇸 | US West (Oregon) | us-west-2 |
| 🇨🇦 | Canada (Central) | ca-central-1 |
| 🇪🇺 | Europe (Frankfurt) | eu-central-1 |
| 🇬🇧 | Europe (London) | eu-west-2 |
| 🇮🇪 | Europe (Ireland) | eu-west-1 |
| 🇫🇷 | Europe (Paris) | eu-west-3 |
| 🇸🇬 | Asia Pacific (Singapore) | ap-southeast-1 |
| 🇦🇺 | Asia Pacific (Sydney) | ap-southeast-2 |
| 🇯🇵 | Asia Pacific (Tokyo) | ap-northeast-1 |

## License 📄

[MIT License](https://github.com/CloudinitFrance/cognito-api/blob/main/LICENSE)
