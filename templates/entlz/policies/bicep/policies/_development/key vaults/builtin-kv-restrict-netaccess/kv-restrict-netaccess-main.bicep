param rgname string = 'policy-testing-rg-kv-restrict-netaccess'
param location string = 'usgovvirginia'

targetScope='subscription'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01'={
  name: rgname
  location: location
}

module assign 'kv-restrict-netaccess-assign.bicep' = {
  name: 'deploy-kv-restrict-netaccess-assign'
  scope: rg
  params: {
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/ac673a9a-f77d-4846-b2d8-a57f8e1c01dc'
    effect: 'Modify'
  }
}
