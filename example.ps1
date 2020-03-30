[CmdletBinding()]
param (
    [Parameter()][string]$AwsAccountId,
    [Parameter()][string]$Account,
    [Parameter()][string]$DefaultPassword,
    [Parameter()][string]$Password,
    [Parameter()][string]$StackName,
    [Parameter()][string]$AwsProfile
)

$outputs = aws cloudformation describe-stacks --output json --stack-name $StackName --profile $AwsProfile --region ap-northeast-1 `
| ConvertFrom-Json | ForEach-Object { $_.Stacks.outputs }

foreach ($output in $outputs) {
    switch ($output.OutputKey) {
        'UserPool' {
            $userPoolId = $output.OutputValue
            break
        }
        'UserPoolClient' {
            $appClientId = $output.OutputValue
            break
        }
        'IdentityPool' {
            $identityPoolId = $output.OutputValue
            break
        }
        Default { }
    }
}

Write-Verbose @{'UserPool' = $userPoolId; 'UserPoolClient' = $appClientId; 'IdentityPool' = $identityPoolId }

Write-Verbose @'
==================== 1. Add User ====================
'@

aws cognito-idp admin-create-user `
    --profile $AwsProfile `
    --region ap-northeast-1 `
    --user-pool-id $userPoolId `
    --username $Account `
    --temporary-password $DefaultPassword `
    --message-action SUPPRESS | Write-Verbose

# initiation.
$res = aws cognito-idp initiate-auth `
    --region ap-northeast-1 `
    --client-id $appClientId `
    --auth-flow USER_PASSWORD_AUTH `
    --auth-parameters "USERNAME=$Account,PASSWORD=$DefaultPassword" `
    --output json | ConvertFrom-Json

# chage password as user.
aws cognito-idp respond-to-auth-challenge `
    --client-id $appClientId `
    --challenge-name NEW_PASSWORD_REQUIRED `
    --challenge-responses "NEW_PASSWORD=$Password,USERNAME=$Account" `
    --session $($res.Session) `
    --region ap-northeast-1 `
    --output json | Write-Verbose
Write-Verbose 'Account activated'

# get token.
$authParams = "USERNAME=$Account,PASSWORD=$Password"
$tokens = aws cognito-idp initiate-auth `
    --region ap-northeast-1 `
    --client-id $appClientId `
    --auth-flow USER_PASSWORD_AUTH `
    --auth-parameters "$authParams" `
    --output json | ConvertFrom-Json

# check token.
aws cognito-idp get-user `
    --access-token $tokens.AuthenticationResult.AccessToken | Write-Verbose

Write-Verbose @'
==================== 2. Get credential. ====================
'@
$tokens = aws cognito-idp initiate-auth `
    --region ap-northeast-1 `
    --client-id $appClientId `
    --auth-flow USER_PASSWORD_AUTH `
    --auth-parameters "$authParams" `
    --output json | ConvertFrom-Json
Write-Verbose $tokens

$logins = "cognito-idp.ap-northeast-1.amazonaws.com/$userPoolId=$($tokens.AuthenticationResult.IdToken)"
Write-Verbose $logins
$identity = aws cognito-identity get-id `
    --account-id $AwsAccountId `
    --region ap-northeast-1 `
    --identity-pool-id "$identityPoolId" `
    --logins "$logins" | ConvertFrom-Json

Write-Verbose $identity

Write-Verbose 'Wait for identity generation...'
Start-Sleep -Seconds 60
$credential = aws cognito-identity get-credentials-for-identity `
    --region ap-northeast-1 `
    --identity-id "$($identity.IdentityId)" `
    --logins "$logins" | ConvertFrom-Json

Write-Verbose $credential
Write-Output $credential.Credentials

