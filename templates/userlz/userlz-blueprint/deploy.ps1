# Az PowerShell
#Login-AzAccount -Environment AzureUSGovernment
#Install-Module -Name Az.Blueprint
New-AzSubscriptionDeployment `
  -Name demoDeployment `
  -Location centralus `
  -TemplateUri "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/subscription-deployments/blueprints-new-blueprint/azuredeploy.json"

Import-AzBlueprintWithArtifact -Name Boilerplate -ManagementGroupId "DevMG" -InputPath  ".\samples\101-boilerplate"
Import-AzBlueprintWithArtifact -n

# Az CLI   
az deployment sub create \
  --name demoDeployment \
  --location usgovvirginia \
  --template-file blueprint.json


  az extension add --name blueprint

  az blueprint import --name az-sample-blueprint --input-path definition