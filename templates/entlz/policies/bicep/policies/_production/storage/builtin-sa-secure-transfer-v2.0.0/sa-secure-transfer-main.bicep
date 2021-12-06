param rgname string = 'policy-testing-rg-sa-secure-transfer'
param location string = 'usgovvirginia'

targetScope='subscription'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01'={
  name: rgname
  location: location
}

module assign 'sa-secure-transfer-assign.bicep' = {
  name: 'deploy-sa-secure-transfer-assign'
  scope: rg
  params: {
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/404c3081-a854-4457-ae30-26a93ef643f9'
  }
}
