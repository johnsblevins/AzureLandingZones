$singlepolicyrg = 'policy-testing-rg-sa-infra-encrypt'
$location = 'usgovvirginia'

# Deploy Bad Test Case
New-AzResourceGroupDeployment -Name 'Deploy-sa-infra-encrypt-Bad-Test-Case' -TemplateFile .\test-case-bad.bicep -ResourceGroupName $singlepolicyrg

# Deploy Good Test Case
New-AzResourceGroupDeployment -Name 'Deploy-sa-infra-encrypt-Good-Test-Case' -TemplateFile .\test-case-good.bicep -ResourceGroupName $singlepolicyrg