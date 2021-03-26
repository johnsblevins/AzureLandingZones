param(
    $DeploymentName = "es-hubspoke-Deployment",
    $TemplateFile = "<local template file>",
    $ParameterFile = "<local parameter file>" ,
    $location = "usgovvirginia"
)

# Login-AzAccount -environment AzureUSGovernment
New-AzTenantDeployment -name $DeploymentName -Location $location -TemplateFile $TemplateFile -TemplateParameterFile $ParameterFile