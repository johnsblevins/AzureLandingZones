$singlepolicyrg = 'policy-testing-rg-allowed-routes'
$location = 'usgovvirginia'

# Deploy Good Test Case
New-AzResourceGroupDeployment -Name 'Deploy-allowed-routes-Good-Test-Case' -TemplateFile .\test-case-good.bicep -ResourceGroupName $singlepolicyrg

# Deploy Bad Test Case
New-AzResourceGroupDeployment -Name 'Deploy-allowed-routes-Route-Bad-Test-Case' -TemplateFile .\test-case-bad.bicep -ResourceGroupName $singlepolicyrg

