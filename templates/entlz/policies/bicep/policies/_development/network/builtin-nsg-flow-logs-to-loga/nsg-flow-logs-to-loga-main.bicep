param rgname string = 'policy-testing-rg-nsg-flow-logs-to-loga'
param location string = 'usgovvirginia'

targetScope='subscription'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01'={
  name: rgname
  location: location
}

module assign 'nsg-flow-logs-to-loga-assign.bicep' = {
  name: 'deploy-nsg-flow-logs-to-loga-assign'
  scope: rg
  params: {
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/e920df7f-9a64-4066-9b58-52684c02a091'
  }
}
