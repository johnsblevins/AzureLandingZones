param rgname string = 'rg-nic-require-nsg-test'
param location string = 'usgovvirginia'

targetScope='subscription'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01'={
  name: rgname
  location: location
}

module def 'nic-require-nsg-def.bicep' = {
  name: 'deploy-nic-require-nsg-def'
}

module assign 'nic-require-nsg-assign.bicep' = {
  name: 'deploy-nic-require-nsg-assign'
  scope: rg
  dependsOn: [
    def
  ]
  params: {
    policyDefinitionId: def.outputs.id
  }
}
