param rgname string 
param location string

targetScope='subscription'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01'={
  name: rgname
  location: location
}

module def 'require-default-route-def.bicep' = {
  name: 'deploy-require-default-route-def'
}

module assign 'require-default-route-assign.bicep' = {
  name: 'deploy-require-default-route-assign'
  dependsOn: [
    def
  ]
  scope: rg  
  params: {
    policyDefinitionId: def.outputs.id
  }
}
