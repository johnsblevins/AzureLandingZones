$singlepolicyrg = 'policy-testing-rg-nsg-flow-logs-to-loga'
$location = 'usgovvirginia'

$allpoliciesrg = 'policy-testing-rg'

# Deploy Policy Assignment - Single Policy RG
New-AzDeployment -Name 'Deploy-nsg-flow-logs-to-loga' -Location usgovvirginia -TemplateFile .\'nsg-flow-logs-to-loga-main.bicep' -rgname $singlepolicyrg -LocationFromTemplate $location

# Deploy Policy Assignment - All Policies RG
New-AzDeployment -Name 'Deploy-nsg-flow-logs-to-loga' -Location usgovvirginia -TemplateFile .\'nsg-flow-logs-to-loga-main.bicep' -rgname $allpoliciesrg -LocationFromTemplate $location

# Start Policy Evaulation Cycle
$singlergjob = Start-AzPolicyComplianceScan -ResourceGroupName $singlepolicyrg -asjob
$allrgjob = Start-AzPolicyComplianceScan -ResourceGroupName $allpoliciesrg -asjob