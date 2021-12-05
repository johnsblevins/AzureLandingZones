$subscription = 'sandbox'
$location = 'usgovvirginia'

Select-AzSubscription -Subscription $subscription

# Deploy Policy Assignment - Single Policy RG
New-AzDeployment -Name 'Deploy-activity-logs-to-loga' -Location $location -TemplateFile .\'activity-logs-to-loga-main.bicep' -LocationFromTemplate $location

# Start Policy Evaulation Cycle
$job = Start-AzPolicyComplianceScan -asjob
