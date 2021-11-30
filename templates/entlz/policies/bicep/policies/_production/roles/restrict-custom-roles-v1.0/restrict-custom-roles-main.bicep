param rgname string = 'rg-restrict-custom-roles-test'
param location string = 'usgovvirginia'

targetScope='subscription'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01'={
  name: rgname
  location: location
}

module def 'restrict-custom-roles-def.bicep' = {
  name: 'deploy-restrict-custom-roles-def'
}

module assign 'restrict-custom-roles-assign.bicep' = {
  name: 'deploy-restrict-custom-roles-assign'
  scope: rg
  dependsOn: [
    def
  ]
  params: {
    policyDefinitionId: def.outputs.id
  }
}
