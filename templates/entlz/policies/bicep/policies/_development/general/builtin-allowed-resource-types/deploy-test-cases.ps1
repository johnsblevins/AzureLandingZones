$singlepolicyrg = 'policy-testing-rg-allowed-resource-types'
$location = 'usgovvirginia'

# Deploy Bad Test Case
New-AzResourceGroupDeployment -Name 'Deploy-allowed-resource-types-Bad-Test-Case' -TemplateFile .\test-case-bad.bicep -ResourceGroupName $singlepolicyrg

# Deploy Good Test Case
New-AzResourceGroupDeployment -Name 'Deploy-allowed-resource-types-Good-Test-Case' -TemplateFile .\test-case-good.bicep -ResourceGroupName $singlepolicyrg