$singlepolicyrg = 'policy-testing-rg-allowed-resource-types'
$location = 'usgovvirginia'

$allpoliciesrg = 'policy-testing-rg'

# Deploy Policy Assignment - Single Policy RG
New-AzDeployment -Name 'Deploy-allowed-resource-types' -Location usgovvirginia -TemplateFile .\'allowed-resource-types-main.bicep' -rgname $singlepolicyrg -LocationFromTemplate $location

# Deploy Policy Assignment - All Policies RG
New-AzDeployment -Name 'Deploy-allowed-resource-types' -Location usgovvirginia -TemplateFile .\'allowed-resource-types-main.bicep' -rgname $allpoliciesrg -LocationFromTemplate $location

# Start Policy Evaulation Cycle
$singlergjob = Start-AzPolicyComplianceScan -ResourceGroupName $singlepolicyrg -asjob
$allrgjob = Start-AzPolicyComplianceScan -ResourceGroupName $allpoliciesrg -asjob