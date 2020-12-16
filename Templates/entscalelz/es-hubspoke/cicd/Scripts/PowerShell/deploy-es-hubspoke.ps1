param(
$DeploymentName = "Deploy es-hubspoke",
$TemplateURI = "https://raw.githubusercontent.com/johnsblevins/AzureLandingZones/master/Templates/ARM/es-hubspoke/cicd/armTemplates/es-hubspoke.json",
$ParameterFile = "c:\temp\es-hubspoke-parameters.json" ,
$location = "usgovvirginia"
)

#Login-AzAccount

New-AzTenantDeployment -name $DeploymentName -Location $location -TemplateUri $TemplateURI -TemplateParameterFile $ParameterFile