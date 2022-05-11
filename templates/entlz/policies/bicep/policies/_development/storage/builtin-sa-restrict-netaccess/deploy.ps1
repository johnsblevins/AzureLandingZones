$singlepolicyrg = 'policy-testing-rg-sa-restrict-netaccess'
$location = 'usgovvirginia'

$allpoliciesrg = 'policy-testing-rg'

# Deploy Policy Assignment - Single Policy RG
New-AzDeployment -Name 'Deploy-sa-restrict-netaccess' -Location usgovvirginia -TemplateFile .\'sa-restrict-netaccess-main.bicep' -rgname $singlepolicyrg -LocationFromTemplate $location

# Deploy Policy Assignment - All Policies RG
New-AzDeployment -Name 'Deploy-sa-restrict-netaccess' -Location usgovvirginia -TemplateFile .\'sa-restrict-netaccess-main.bicep' -rgname $allpoliciesrg -LocationFromTemplate $location

# Start Policy Evaulation Cycle
$singlergjob = Start-AzPolicyComplianceScan -ResourceGroupName $singlepolicyrg -asjob
$allrgjob = Start-AzPolicyComplianceScan -ResourceGroupName $allpoliciesrg -asjob