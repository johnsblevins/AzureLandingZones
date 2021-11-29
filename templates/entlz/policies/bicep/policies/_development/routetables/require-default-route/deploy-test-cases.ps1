# Deploy Good Test Case
New-AzResourceGroupDeployment -Name 'Deploy-Require-Default-Route-Good-Test-Case' -TemplateFile .\test-case-good.bicep -ResourceGroupName $singlepolicyrg

# Deploy Bad Test Case
New-AzResourceGroupDeployment -Name 'Deploy-Require-Default-Route-Bad-Test-Case' -TemplateFile .\test-case-bad.bicep -ResourceGroupName $singlepolicyrg

