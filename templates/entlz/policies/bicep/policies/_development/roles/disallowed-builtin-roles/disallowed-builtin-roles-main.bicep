param rgname string = 'rg-disallowed-builtin-roles-test'
param location string = 'usgovvirginia'

targetScope='subscription'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01'={
  name: rgname
  location: location
}

module def 'disallowed-builtin-roles-def.bicep' = {
  name: 'deploy-disallowed-builtin-roles-def'
}

module assign 'disallowed-builtin-roles-assign.bicep' = {
  name: 'deploy-disallowed-builtin-roles-assign'
  scope: rg
  dependsOn: [
    def
  ]
  params: {
    policyDefinitionId: def.outputs.id
  }
}
