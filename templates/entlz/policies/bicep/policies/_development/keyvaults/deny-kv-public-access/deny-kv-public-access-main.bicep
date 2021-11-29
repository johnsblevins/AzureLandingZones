param rgname string = 'rg-deny-kv-public-access'
param location string = 'usgovvirginia'

targetScope='subscription'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01'={
  name: rgname
  location: location
}

module def 'deny-kv-public-access-def.bicep' = {
  name: 'deploy-deny-kv-public-access-def'
}

module assign 'deny-kv-public-access-assign.bicep' = {
  name: 'deploy-deny-kv-public-access-assign'
  scope: rg
  dependsOn: [
    def
  ]
  params: {
    policyDefinitionId: def.outputs.id
  }
}
