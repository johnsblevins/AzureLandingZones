$enterpriseScaleCompanyPrefix = "jsb"

# Get Management Groups Starting with Prefix Root
$mgs = Get-AzManagementGroup -GroupName $enterpriseScaleCompanyPrefix -Recurse -Expand

# Get All Subs in Management Group Structure
$subs =@()
function Resolve-Properties 
{
  param([Parameter(ValueFromPipeline)][object]$InputObject)

  process {
    if($InputObject.type -eq "/providers/Microsoft.Management/managementGroups")
    {
        foreach($child in $InputObject.children){
        Resolve-Properties $child
        }
    }
    elseif ($child.type -eq "/subscriptions") {
        return( $child.id.replace('/subscriptions/','') )
        #write-host ( $child.id.replace('/subscriptions/','') )
        #$subs += ( $child.id.replace('/subscriptions/','') )
    }
  }
}
$subs += Resolve-Properties $mgs.children

# Get all policies at Prefix Scope
$pols = (Get-AzPolicyDefinition -Custom ) | where { $_.resourceid -like "/providers/Microsoft.Management/managementGroups/$enterpriseScaleCompanyPrefix*"}

# Get all policy set definitions at prefix scope
$polsets = (Get-AzPolicySetDefinition  -Custom ) | where { $_.resourceid -like "/providers/Microsoft.Management/managementGroups/$enterpriseScaleCompanyPrefix*"}



foreach ($sub in $subs) {
    Select-AzSubscription $sub
    $rgs = Get-AzResourceGroup
    foreach($rg in $rgs)
    {
        write-host $rg.ResourceGroupName
        if ($rg.ResourceGroupName -like "*-connectivity" -or $rg.ResourceGroupName -like "*-mgmt")
        {
                write-host $rg.resourcegroupname
            #Remove-AzResourceGroup -Name $rg.ResourceGroupName -Force
        }
    }
}

foreach($polset in $polsets)
{
    write-host $polset.resourceid
    $assignment =  Get-AzPolicyAssignment -PolicyDefinitionId $polset.ResourceId -ErrorAction Ignore
    write-host $assignment
    #remove-azpolicyassignment -Id $assignment.PolicyAssignmentId 
}

$policyAssignments = get-azpolicyassignment
foreach($policyAssignment in $policyAssignments)
{
    if ($policyAssignment.name -in ("DataProtectionSecurityCenter","Deny-IP-forwarding","Deny-Storage-http","Deny-Subnet-Without-Nsg","Deploy-SQL-DB-Auditing","Deploy-VM-Backup","Enforce-SQL-Encryption","Deploy-ASC-Monitoring","Deploy-ASC-Security","Deploy-AzActivity-Log","Deploy-Resource-Diag","Deploy-VM-Monitoring","Deploy-VMSS-Monitoring"))
    {
        write-host $policyAssignment.name
    }
}


}