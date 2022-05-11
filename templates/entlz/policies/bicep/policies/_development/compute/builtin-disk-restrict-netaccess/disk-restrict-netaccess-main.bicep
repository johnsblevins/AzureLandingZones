param rgname string = 'policy-testing-rg-disk-restrict-netaccess'
param location string = 'usgovvirginia'

targetScope='subscription'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01'={
  name: rgname
  location: location
}

module assign 'disk-restrict-netaccess-assign.bicep' = {
  name: 'deploy-disk-restrict-netaccess-assign'
  scope: rg
  params: {
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/a08ec900-254a-4555-9bf5-e42af04b5c5c'
  }
}
