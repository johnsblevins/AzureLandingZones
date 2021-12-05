$singlepolicyrg = 'policy-testing-rg-restrict-custom-roles'
$location = 'usgovvirginia'

# Deploy Bad Test Case
New-AzResourceGroupDeployment -Name 'Deploy-restrict-custom-roles-Bad-Test-Case' -TemplateFile .\test-case-bad.bicep -ResourceGroupName $singlepolicyrg


# Deploy Good Test Case
New-AzResourceGroupDeployment -Name 'Deploy-restrict-custom-roles-Good-Test-Case' -TemplateFile .\test-case-good.bicep -ResourceGroupName $singlepolicyrg