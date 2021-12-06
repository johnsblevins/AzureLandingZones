param rgname string = 'policy-testing-rg-sa-restrict-netaccess'
param location string = 'usgovvirginia'

targetScope='subscription'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01'={
  name: rgname
  location: location
}

module assign 'sa-restrict-netaccess-assign.bicep' = {
  name: 'deploy-sa-restrict-netaccess-assign'
  scope: rg
  params: {
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/34c877ad-507e-4c82-993e-3452a6e0ad3c'
  }
}
