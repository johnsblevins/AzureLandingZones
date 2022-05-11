$singlepolicyrg = 'policy-testing-rg-disallowed-roles'
$location = 'usgovvirginia'

# Deploy Bad Test Case
New-AzResourceGroupDeployment -Name 'Deploy-disallowed-roles-Bad-Test-Case' -TemplateFile .\test-case-bad.bicep -ResourceGroupName $singlepolicyrg


# Deploy Good Test Case
New-AzResourceGroupDeployment -Name 'Deploy-disallowed-roles-Good-Test-Case' -TemplateFile .\test-case-good.bicep -ResourceGroupName $singlepolicyrg