param rgname string = 'rg-disallowed-roles-test'
param location string = 'usgovvirginia'

targetScope='subscription'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01'={
  name: rgname
  location: location
}

module def 'disallowed-roles-def.bicep' = {
  name: 'deploy-disallowed-roles-def'
}

module assign 'disallowed-roles-assign.bicep' = {
  name: 'deploy-disallowed-roles-assign'
  scope: rg
  dependsOn: [
    def
  ]
  params: {
    policyDefinitionId: def.outputs.id
  }
}
