$apps = Get-AzADApplication
$app_assignments = Get-AzRoleAssignment | ? {$_.ObjectType -ne "User"}

$app_assignment_details = @()

foreach ($app_assignment in $app_assignments)
{
    $app_sp = Get-AzADServicePrincipal -ObjectId $app_assignment.ObjectId
    $app_id = $app_sp.ApplicationId

    $app_assignment_detail = new-object System.Object

    if ($app_assignment.DisplayName)
    {
        $app_assignment_detail | add-member -type NoteProperty -name DisplayName -value $app_assignment.DisplayName
    }
    else {
        $app_assignment_detail | add-member -type NoteProperty -name DisplayName -value "UNKNOWN"
    }


    if ($app_assignment.Scope -eq "/")
    {
        $app_assignment_detail | add-member -type NoteProperty -name ScopeLevel -value "Tenant"
        $app_assignment_detail | add-member -type NoteProperty -name ScopeName -value ""
    }
    else {
        $app_assignment_detail | add-member -type NoteProperty -name ScopeLevel -value ($app_assignment.Scope.split("/")[-2])
        $app_assignment_detail | add-member -type NoteProperty -name ScopeName -value ($app_assignment.Scope.split("/")[-1])
    }

    $app_assignment_detail | add-member -type NoteProperty -name Role -value $app_assignment.RoleDefinitionName

    $app_credentials = Get-AzADApplication -ApplicationId $app_id | Get-AzADAppCredential
    $app_credential_count = $app_credentials.count
    $app_assignment_detail | add-member -type NoteProperty -name SecretCount -value $app_credential_Count
    $app_assignment_detail | add-member -type NoteProperty -name AppID -value $app_id

    if ($app_credentials_count -gt 0)
    {   
        
        foreach($app_credential in $app_credentials)
        {
            #$app_assignment_detail | add-member -type NoteProperty -name CredType -value $app_credential.type
            #$app_assignment_detail | add-member -type NoteProperty -name CredStartDate -value $app_credential.startdate
            #$app_assignment_detail | add-member -type NoteProperty -name CredEndDate -value $app_credential.enddate        
            #$app_assignment_details += $app_assignment_detail
        }
    }
    else 
    {
            #$app_assignment_detail | add-member -type NoteProperty -name CredType -value "No Creds"
            #$app_assignment_detail | add-member -type NoteProperty -name CredStartDate -value ""
            #$app_assignment_detail | add-member -type NoteProperty -name CredEndDate -value "" 
            #$app_assignment_details += $app_assignment_detail
    }
    $app_assignment_details += $app_assignment_detail
}
$app_assignment_details