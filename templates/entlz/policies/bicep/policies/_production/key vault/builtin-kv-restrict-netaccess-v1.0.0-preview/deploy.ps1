$singlepolicyrg = 'policy-testing-rg-kv-restrict-netaccess'
$location = 'usgovvirginia'

$allpoliciesrg = 'policy-testing-rg'

# Deploy Policy Assignment - Single Policy RG
New-AzDeployment -Name 'Deploy-kv-restrict-netaccess' -Location usgovvirginia -TemplateFile .\'kv-restrict-netaccess-main.bicep' -rgname $singlepolicyrg -LocationFromTemplate $location

# Deploy Policy Assignment - All Policies RG
New-AzDeployment -Name 'Deploy-kv-restrict-netaccess' -Location usgovvirginia -TemplateFile .\'kv-restrict-netaccess-main.bicep' -rgname $allpoliciesrg -LocationFromTemplate $location

# Start Policy Evaulation Cycle
$singlergjob = Start-AzPolicyComplianceScan -ResourceGroupName $singlepolicyrg -asjob
$allrgjob = Start-AzPolicyComplianceScan -ResourceGroupName $allpoliciesrg -asjob