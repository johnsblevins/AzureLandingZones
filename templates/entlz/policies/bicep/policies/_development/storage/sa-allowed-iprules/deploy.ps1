$singlepolicyrg = 'policy-testing-rg-sa-allowed-iprules'
$location = 'usgovvirginia'

$allpoliciesrg = 'policy-testing-rg'

# Deploy Policy Definition and Assignment - Single Policy RG
New-AzDeployment -Name 'Deploy-sa-allowed-iprules' -Location usgovvirginia -TemplateFile .\sa-allowed-iprules-main.bicep -rgname $singlepolicyrg -LocationFromTemplate $location

# Deploy Policy Definition and Assignment - All Policies RG
New-AzDeployment -Name 'Deploy-sa-allowed-iprules' -Location usgovvirginia -TemplateFile .\sa-allowed-iprules-main.bicep -rgname $allpoliciesrg -LocationFromTemplate $location

# Start Policy Evaulation Cycle
$singlepolicyrg = 'policy-testing-rg-sa-allowed-iprules'
$location = 'usgovvirginia'
$allrgjob = Start-AzPolicyComplianceScan -ResourceGroupName $allpoliciesrg -asjob