$singlepolicyrg = 'policy-testing-rg-allowed-vnet-peers'
$location = 'usgovvirginia'

# Deploy Good Test Case
New-AzResourceGroupDeployment -Name 'Deploy-allowed-vnet-peers-Good-Test-Case' -TemplateFile .\test-case-good.bicep -ResourceGroupName $singlepolicyrg

# Deploy Bad Test Case
New-AzResourceGroupDeployment -Name 'Deploy-allowed-vnet-peers-Route-Bad-Test-Case' -TemplateFile .\test-case-bad.bicep -ResourceGroupName $singlepolicyrg

