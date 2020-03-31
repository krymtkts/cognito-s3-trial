# Cognito S3 Trial

## How to make CloudFormation stack ?

The stack name becomes the bucket name, so you can use lowercase letters.

```sh
# create stack
aws cloudformation create-stack --stack-name yourstackname --template-body file://template.yaml --profile YourProfile --region ap-northeast-1 --capabilities CAPABILITY_IAM

# delete stack
aws cloudformation delete-stack --stack-name yourstackname --profile YourProfile --region ap-northeast-1
```

## Create a Cognito user and get credential

```powershell
$cre = .\example.ps1 -AwsAccountId 123456789012 -Account 'ACCOUNT1' -DefaultPassword 'TemporaryPassword!' -Password 'NewPassword!' -AwsProfile YourProfile -StackName yourstackname
$cre
# AccessKeyId          SecretKey                                SessionToken
# -----------          ---------                                ------------
# XXXXXXXXXXXXXXXXXXXX xxxxxxxxxx.....                          XXXXXXXXXXXXXXXX....

```
