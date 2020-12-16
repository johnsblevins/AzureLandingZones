#Login-AzAccount -Environment AzureUSGovernment
Install-Module -Name Az.Blueprint
Import-AzBlueprintWithArtifact -Name "fedrampmod" -ManagementGroupId "<root mg Id>" -InputPath  "<path to blueprint template>" -Force


az blueprint import --name MyBlueprint \
--input-path "path/to/blueprint/directory"