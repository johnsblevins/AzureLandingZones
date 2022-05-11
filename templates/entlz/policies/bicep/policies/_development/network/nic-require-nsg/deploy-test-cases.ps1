$singlepolicyrg = 'policy-testing-rg-nic-require-nsg'
$location = 'usgovvirginia'

# Deploy Bad Test Case
New-AzResourceGroupDeployment -Name 'Deploy-nic-require-nsg-Bad-Test-Case' -TemplateFile .\test-case-bad.bicep -ResourceGroupName $singlepolicyrg

# Deploy Good Test Case
New-AzResourceGroupDeployment -Name 'Deploy-nic-require-nsg-Good-Test-Case' -TemplateFile .\test-case-good.bicep -ResourceGroupName $singlepolicyrg