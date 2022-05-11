param rgname string = 'rg-allowed-vnet-peers-test'
param location string = 'usgovvirginia'
targetScope='subscription'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01'={
  name: rgname
  location: location
}

module def 'allowed-vnet-peers-def.bicep' = {
  name: 'deploy-allowed-vnet-peers-def'
}

module assign 'allowed-vnet-peers-assign.bicep' = {
  name: 'deploy-allowed-vnet-peers-assign'
  dependsOn: [
    def
  ]
  scope: rg  
}
