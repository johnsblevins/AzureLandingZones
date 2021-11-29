targetScope='resourceGroup'

var roledefinitionid = subscriptionResourceId('Microsoft.Authorization/roleDefinitions','18d7d88d-d35e-4fb5-a5c3-7773c20a72d9') // User Access Administrator

resource goodroleassignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview'= {
  name: 'c5a98745-4ef9-409c-a3d5-4b82de4c27d5'
  properties: {
    principalId: '463ee05d-a5dd-4332-9946-538d9fe193e5'
    roleDefinitionId: roledefinitionid
  }
}
