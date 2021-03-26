# Az PowerShell
#Login-AzAccount -Environment AzureUSGovernment
#Install-Module -Name Az.Blueprint
Import-AzBlueprintWithArtifact -Name "sandbox" -ManagementGroupId "EnterCustomMG" -InputPath "path/to/blueprint/directory"

# Az CLI   
az blueprint import --name sandbox --input-path "path/to/blueprint/directory" --management-group "EnterCustomMG"