param (
    [string]$esPrefix="",
    [string]$managementSubId="",
    [string]$connectivitySubId="",
    [string]$IdentitySubId="",
    [string]$securitySubId=""
)

#Login-AzAccount -Environment AzureUSGovernment

Select-AzSubscription $securitySubId
$rgsToRemove=("$esPrefix-security-connectivity","NetworkWatcherRG")
foreach($rg in $rgsToRemove)
{
    Remove-AzResourceGroup -Name $rg -Force
}

Select-AzSubscription $identitySubId
$rgsToRemove=("$esPrefix-identity-connectivity","NetworkWatcherRG")
foreach($rg in $rgsToRemove)
{
    Remove-AzResourceGroup -Name $rg -Force
}

Select-AzSubscription $managementSubId
$rgsToRemove=("$esPrefix-mgmt","$esPrefix-mgmt-connectivity","NetworkWatcherRG")
foreach($rg in $rgsToRemove)
{
    Remove-AzResourceGroup -Name $rg -Force
}

Select-AzSubscription $connectivitySubId
$rgsToRemove=("$esPrefix-connectivity","NetworkWatcherRG")
foreach($rg in $rgsToRemove)
{
    Remove-AzResourceGroup -Name $rg -Force
}

Remove-AzManagementGroup -GroupName "$esPrefix-Sandbox-LandingZones"
remove-azmanagementgroup -GroupName "$esPrefix-Sandbox-Management"
remove-azmanagementgroup -GroupName "$esPrefix-internal-prod"
remove-azmanagementgroup -GroupName "$esPrefix-internal-nonprod"
remove-azmanagementgroup -GroupName "$esPrefix-internal"
remove-azmanagementgroup -GroupName "$esPrefix-external-prod"
remove-azmanagementgroup -GroupName "$esPrefix-external-nonprod"
remove-azmanagementgroup -GroupName "$esPrefix-external"
Remove-AzManagementGroupSubscription -GroupName "$esPrefix-connectivity" -SubscriptionId $connectivitySubId
remove-azmanagementgroup -GroupName "$esPrefix-connectivity"
Remove-AzManagementGroupSubscription -GroupName "$esPrefix-management" -SubscriptionId $managementSubId
remove-azmanagementgroup -GroupName "$esPrefix-management"
Remove-AzManagementGroupSubscription -GroupName "$esPrefix-identity" -SubscriptionId $IdentitySubId
remove-azmanagementgroup -GroupName "$esPrefix-identity"
Remove-AzManagementGroupSubscription -GroupName "$esPrefix-security" -SubscriptionId $securitySubId
remove-azmanagementgroup -GroupName "$esPrefix-security"
remove-azmanagementgroup -GroupName "$esPrefix-platform"
remove-azmanagementgroup -GroupName "$esPrefix-landingzones"
remove-azmanagementgroup -GroupName "$esPrefix-decommissioned"
remove-azmanagementgroup -GroupName "$esPrefix-sandboxes"
remove-azmanagementgroup -GroupName "$esPrefix"
