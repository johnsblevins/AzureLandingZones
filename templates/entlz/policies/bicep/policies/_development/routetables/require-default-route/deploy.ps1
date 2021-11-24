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

# Deploy Good Test Case
New-AzResourceGroupDeployment -Name 'Deploy-Require-Default-Route-Good-Test-Case' -TemplateFile .\test-case-good.bicep -ResourceGroupName $singlepolicyrg

# Deploy Bad Test Case
New-AzResourceGroupDeployment -Name 'Deploy-Require-Default-Route-Bad-Test-Case' -TemplateFile .\test-case-bad.bicep -ResourceGroupName $singlepolicyrg

