# Grant Permission for Sub Vendor Account to Create Subs
$subCreatorObjId = "8b68b348-cf9b-436e-9d4b-a9633dc1c204" # Object Id of User, Group or Service Prinicpal who needs to create Subs
$enrAcctObjId = (get-azenrollmentaccount).objectId
az billing enrollmnet-account
New-AzRoleAssignment -RoleDefinitionName Owner -ObjectId $subCreatorObjId -Scope /providers/Microsoft.Billing/enrollmentAccounts/$enrAcctObjId
az role assignment list --scope /providers/Microsoft.Billing/enrollmentAccounts/$enrAcctObjId


[--all]
                        [--assignee]
                        [--include-classic-administrators {false, true}]
                        [--include-groups]
                        [--include-inherited]
                        [--query-examples]
                        [--resource-group]
                        [--role]
                        [--scope]
                        [--subscription]



# Create Sub
$subOwnerObjId = "8b68b348-cf9b-436e-9d4b-a9633dc1c204" # Object Id of User, Group or Service Principal who needs to own Subs
#$enrAcctObjId = (get-azenrollmentaccount).objectId
$subName = "DoNotUse14"
$offerType = "MS-AZR-USGOV-0017P"
$azContext = Get-AzContext
$azProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
$profileClient = New-Object -TypeName Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient -ArgumentList ($azProfile)
$token = $profileClient.AcquireAccessToken($azContext.Subscription.TenantId)
$token = $profileClient.AcquireAccessToken($azContext.Subscription.TenantId)
$authHeader = @{
    'Content-Type'='application/json'
    'Authorization'='Bearer ' + $token.AccessToken
}
$body = @"
{
    "displayName": "$subName",
    "offerType": "$offerType",
    "owners": [
      {
        "objectId": "$subOwnerObjId"
      }
    ]
  }
"@
$random_guid = New-Guid
$restUri = "https://management.usgovcloudapi.net/providers/Microsoft.Billing/enrollmentAccounts/$enrAcctObjId/providers/Microsoft.Subscription/createSubscription?api-version=2019-10-01-preview"
$response = Invoke-RestMethod -Uri $restUri -Method Post -Headers $authHeader -Body $body