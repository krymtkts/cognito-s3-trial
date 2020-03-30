# Cognito S3 Trial

## How to make CloudFormation stack ?

```sh
# create stack
aws cloudformation create-stack --stack-name YourStackName --template-body file://template.yaml --profile YourProfile --region ap-northeast-1 --capabilities CAPABILITY_IAM

# delete stack
aws cloudformation delete-stack --stack-name YourStackName --profile YourProfile --region ap-northeast-1
```

## Create a Cognito user and get credential

```powershell
$cre = .\example.ps1 -AwsAccountId 123456789012 -Account 'ACCOUNT1' -DefaultPassword 'TemporaryPassword!' -Password 'NewPassword!' -AwsProfile YourProfile -StackName YourStackName
$cre
# AccessKeyId          SecretKey                                SessionToken
# -----------          ---------                                ------------
# XXXXXXXXXXXXXXXXXXXX xxxxxxxxxx.....                          XXXXXXXXXXXXXXXX....

```
