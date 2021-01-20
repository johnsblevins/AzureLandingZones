param(
    $DeploymentName = "es-hubspoke-Deployment",
    $TemplateURI = "https://raw.githubusercontent.com/johnsblevins/AzureLandingZones/master/Templates/entscalelz/es-hubspoke-template/es-hubspoke.json",
    $ParameterFile = "<local parameter file>" ,
    $location = "usgovvirginia"
)

#Login-AzAccount
New-AzTenantDeployment -name $DeploymentName -Location $location -TemplateUri $TemplateURI -TemplateParameterFile $ParameterFile