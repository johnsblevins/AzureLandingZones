$singlepolicyrg = 'policy-testing-rg-restrict-custom-roles-test'
$location = 'usgovvirginia'

$allpoliciesrg = 'policy-testing-rg'

# Deploy Policy Definition and Assignment - Single Policy RG
New-AzDeployment -Name 'Deploy-restrict-custom-roles' -Location usgovvirginia -TemplateFile .\restrict-custom-roles-main.bicep -rgname $singlepolicyrg -LocationFromTemplate $location

# Deploy Policy Definition and Assignment - All Policies RG
New-AzDeployment -Name 'Deploy-restrict-custom-roles' -Location usgovvirginia -TemplateFile .\restrict-custom-roles-main.bicep -rgname $allpoliciesrg -LocationFromTemplate $location

# Start Policy Evaulation Cycle
#$singlergjob = Start-AzPolicyComplianceScan -ResourceGroupName $singlepolicyrg -asjob
#$allrgjob = Start-AzPolicyComplianceScan -ResourceGroupName $allpoliciesrg -asjob

# Deploy Good Test Case
#New-AzResourceGroupDeployment -Name 'Deploy-restrict-custom-roles-Good-Test-Case' -TemplateFile .\test-case-good.bicep -ResourceGroupName $singlepolicyrg

# Deploy Bad Test Case
#New-AzResourceGroupDeployment -Name 'Deploy-restrict-custom-roles-Bad-Test-Case' -TemplateFile .\test-case-bad.bicep -ResourceGroupName $singlepolicyrg

