param rgname string = 'policy-testing-rg-sa-infra-encrypt'
param location string = 'usgovvirginia'

targetScope='subscription'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01'={
  name: rgname
  location: location
}

module assign 'sa-infra-encrypt-assign.bicep' = {
  name: 'deploy-sa-infra-encrypt-assign'
  scope: rg
  params: {
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/4733ea7b-a883-42fe-8cac-97454c2a9e4a'
  }
}
