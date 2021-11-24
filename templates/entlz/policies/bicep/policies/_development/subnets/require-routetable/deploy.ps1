$singlepolicyrg = 'policy-testing-rg-require-routetable-test'
$location = 'usgovvirginia'

$allpoliciesrg = 'policy-testing-rg'

# Deploy Policy Definition and Assignment - Single Policy RG
New-AzDeployment -Name 'Deploy-Require-routetable' -Location usgovvirginia -TemplateFile .\require-routetable-main.bicep -rgname $singlepolicyrg -LocationFromTemplate $location

# Deploy Policy Definition and Assignment - All Policies RG
New-AzDeployment -Name 'Deploy-Require-routetable' -Location usgovvirginia -TemplateFile .\require-routetable-main.bicep -rgname $allpoliciesrg -LocationFromTemplate $location

# Start Policy Evaulation Cycle
$singlergjob = Start-AzPolicyComplianceScan -ResourceGroupName $singlepolicyrg -asjob
$allrgjob = Start-AzPolicyComplianceScan -ResourceGroupName $allpoliciesrg -asjob

# Deploy Good Test Case
New-AzResourceGroupDeployment -Name 'Deploy-Require-routetable-Good-Test-Case' -TemplateFile .\test-case-good.bicep -ResourceGroupName $singlepolicyrg

# Deploy Bad Test Case
New-AzResourceGroupDeployment -Name 'Deploy-Require-routetable-Bad-Test-Case' -TemplateFile .\test-case-bad.bicep -ResourceGroupName $singlepolicyrg

