param rgname string = 'policy-testing-rg-nic-disable-ipforward'
param location string = 'usgovvirginia'

targetScope='subscription'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01'={
  name: rgname
  location: location
}

module assign 'nic-disable-ipforward-assign.bicep' = {
  name: 'deploy-nic-disable-ipforward-assign'
  scope: rg
  params: {
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/88c0b9da-ce96-4b03-9635-f29a937e2900'
  }
}
