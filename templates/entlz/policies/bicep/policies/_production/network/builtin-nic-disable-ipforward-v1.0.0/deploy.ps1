$singlepolicyrg = 'policy-testing-rg-nic-disable-ipforward'
$location = 'usgovvirginia'

$allpoliciesrg = 'policy-testing-rg'

# Deploy Policy Assignment - Single Policy RG
New-AzDeployment -Name 'Deploy-nic-disable-ipforward' -Location usgovvirginia -TemplateFile .\'nic-disable-ipforward-main.bicep' -rgname $singlepolicyrg -LocationFromTemplate $location

# Deploy Policy Assignment - All Policies RG
New-AzDeployment -Name 'Deploy-nic-disable-ipforward' -Location usgovvirginia -TemplateFile .\'nic-disable-ipforward-main.bicep' -rgname $allpoliciesrg -LocationFromTemplate $location

# Start Policy Evaulation Cycle
$singlergjob = Start-AzPolicyComplianceScan -ResourceGroupName $singlepolicyrg -asjob
$allrgjob = Start-AzPolicyComplianceScan -ResourceGroupName $allpoliciesrg -asjob