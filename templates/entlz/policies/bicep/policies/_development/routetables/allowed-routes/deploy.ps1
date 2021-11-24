$singlepolicyrg = 'policy-testing-rg-allowed-routes-test'
$location = 'usgovvirginia'

$allpoliciesrg = 'policy-testing-rg'

# Deploy Policy Definition and Assignment - Single Policy RG
New-AzDeployment -Name 'Deploy-allowed-routes' -Location usgovvirginia -TemplateFile .\allowed-routes-main.bicep -rgname $singlepolicyrg -LocationFromTemplate $location

# Deploy Policy Definition and Assignment - All Policies RG
New-AzDeployment -Name 'Deploy-allowed-routes' -Location usgovvirginia -TemplateFile .\allowed-routes-main.bicep -rgname $allpoliciesrg -LocationFromTemplate $location

# Start Policy Evaulation Cycle
$singlergjob = Start-AzPolicyComplianceScan -ResourceGroupName $singlepolicyrg -asjob
$allrgjob = Start-AzPolicyComplianceScan -ResourceGroupName $allpoliciesrg -asjob

# Deploy Good Test Case
New-AzResourceGroupDeployment -Name 'Deploy-allowed-routes-Good-Test-Case' -TemplateFile .\test-case-good.bicep -ResourceGroupName $singlepolicyrg

# Deploy Bad Test Case
New-AzResourceGroupDeployment -Name 'Deploy-allowed-routes-Bad-Test-Case' -TemplateFile .\test-case-bad.bicep -ResourceGroupName $singlepolicyrg

