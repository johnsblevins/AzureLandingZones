$allpoliciesrg = 'policy-testing-rg'

New-AzResourceGroupDeployment -Name 'Deploy-Master-Test-Case' -TemplateFile .\master.bicep -ResourceGroupName $allpoliciesrg

