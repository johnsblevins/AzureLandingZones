$singlepolicyrg = 'policy-testing-rg-kv-restrict-netaccess'
$location = 'usgovvirginia'

# Deploy Bad Test Case
New-AzResourceGroupDeployment -Name 'Deploy-kv-restrict-netaccess-Bad-Test-Case' -TemplateFile .\test-case-bad.bicep -ResourceGroupName $singlepolicyrg

# Deploy Good Test Case
New-AzResourceGroupDeployment -Name 'Deploy-kv-restrict-netaccess-Good-Test-Case' -TemplateFile .\test-case-good.bicep -ResourceGroupName $singlepolicyrg