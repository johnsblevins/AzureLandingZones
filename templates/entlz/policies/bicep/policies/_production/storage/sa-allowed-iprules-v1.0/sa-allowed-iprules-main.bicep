param rgname string = 'rg-sa-allowed-iprules-test'
param location string = 'usgovvirginia'

targetScope='subscription'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01'={
  name: rgname
  location: location
}

module def 'sa-allowed-iprules-def.bicep' = {
  name: 'deploy-sa-allowed-iprules-def'
}

module assign 'sa-allowed-iprules-assign.bicep' = {
  name: 'deploy-sa-allowed-iprules-assign'
  scope: rg
  dependsOn: [
    def
  ]
  params: {
    policyDefinitionId: def.outputs.id
  }
}
