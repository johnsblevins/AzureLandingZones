$singlepolicyrg = 'policy-testing-rg-require-routetable'
$location = 'usgovvirginia'

# Deploy Good Test Case
New-AzResourceGroupDeployment -Name 'Deploy-Require-Routetable-Good-Test-Case' -TemplateFile .\test-case-good.bicep -ResourceGroupName $singlepolicyrg

# Deploy Bad Test Case
New-AzResourceGroupDeployment -Name 'Deploy-Require-Routetable-Bad-Test-Case' -TemplateFile .\test-case-bad.bicep -ResourceGroupName $singlepolicyrg

