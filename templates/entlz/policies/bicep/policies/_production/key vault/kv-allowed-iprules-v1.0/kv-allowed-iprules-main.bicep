param rgname string = 'rg-kv-allowed-iprules-test'
param location string = 'usgovvirginia'

targetScope='subscription'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01'={
  name: rgname
  location: location
}

module def 'kv-allowed-iprules-def.bicep' = {
  name: 'deploy-kv-allowed-iprules-def'
}

module assign 'kv-allowed-iprules-assign.bicep' = {
  name: 'deploy-kv-allowed-iprules-assign'
  scope: rg
  dependsOn: [
    def
  ]
  params: {
    policyDefinitionId: def.outputs.id
  }
}
