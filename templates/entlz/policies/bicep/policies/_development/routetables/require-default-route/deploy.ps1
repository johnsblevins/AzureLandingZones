$singlepolicyrg = 'policy-testing-rg-require-default-route-test'
$location = 'usgovvirginia'

$allpoliciesrg = 'policy-testing-rg'

# Deploy Policy Definition and Assignment - Single Policy RG
New-AzDeployment -Name 'Deploy-Require-Default-Route' -Location usgovvirginia -TemplateFile .\require-default-route-main.bicep -rgname $singlepolicyrg -LocationFromTemplate $location

# Deploy Policy Definition and Assignment - All Policies RG
New-AzDeployment -Name 'Deploy-Require-Default-Route' -Location usgovvirginia -TemplateFile .\require-default-route-main.bicep -rgname $allpoliciesrg -LocationFromTemplate $location

# Start Policy Evaulation Cycle
$singlergjob = Start-AzPolicyComplianceScan -ResourceGroupName $singlepolicyrg -asjob
$allrgjob = Start-AzPolicyComplianceScan -ResourceGroupName $allpoliciesrg -asjob