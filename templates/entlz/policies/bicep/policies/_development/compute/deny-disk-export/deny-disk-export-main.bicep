param rgname string = 'rg-deny-disk-export'
param location string = 'usgovvirginia'

targetScope='subscription'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01'={
  name: rgname
  location: location
}

module def 'deny-disk-export-def.bicep' = {
  name: 'deploy-deny-disk-export-def'
}

module assign 'deny-disk-export-assign.bicep' = {
  name: 'deploy-deny-disk-export-assign'
  scope: rg
  dependsOn: [
    def
  ]
  params: {
    policyDefinitionId: def.outputs.id
  }
}
