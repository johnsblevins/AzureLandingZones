$singlepolicyrg = 'policy-testing-rg-deny-disk-export'
$location = 'usgovvirginia'

# Deploy Bad Test Case
New-AzResourceGroupDeployment -Name 'Deploy-deny-disk-export-Bad-Test-Case' -TemplateFile .\test-case-bad.bicep -ResourceGroupName $singlepolicyrg

# Deploy Good Test Case
New-AzResourceGroupDeployment -Name 'Deploy-deny-disk-export-Good-Test-Case' -TemplateFile .\test-case-good.bicep -ResourceGroupName $singlepolicyrg