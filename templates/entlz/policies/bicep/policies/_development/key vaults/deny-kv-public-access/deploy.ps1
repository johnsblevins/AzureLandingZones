$singlepolicyrg = 'policy-testing-rg-deny-kv-public-access'
$location = 'usgovvirginia'

$allpoliciesrg = 'policy-testing-rg'

# Deploy Policy Definition and Assignment - Single Policy RG
New-AzDeployment -Name 'Deploy-deny-kv-public-access' -Location usgovvirginia -TemplateFile .\deny-kv-public-access-main.bicep -rgname $singlepolicyrg -LocationFromTemplate $location

# Deploy Policy Definition and Assignment - All Policies RG
New-AzDeployment -Name 'Deploy-deny-kv-public-access' -Location usgovvirginia -TemplateFile .\deny-kv-public-access-main.bicep -rgname $allpoliciesrg -LocationFromTemplate $location

# Start Policy Evaulation Cycle
$singlergjob = Start-AzPolicyComplianceScan -ResourceGroupName $singlepolicyrg -asjob
$allrgjob = Start-AzPolicyComplianceScan -ResourceGroupName $allpoliciesrg -asjob