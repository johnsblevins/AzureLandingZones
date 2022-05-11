targetScope='resourceGroup'

var roledefinitionid = subscriptionResourceId('Microsoft.Authorization/roleDefinitions','8e3af657-a8ff-443c-a75c-2fe8c4bcb635') // Owner

resource badroleassignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview'= {
  name: '218b649f-d1d3-46cf-bb89-cd805a4c4c18'
  properties: {
    principalId: '463ee05d-a5dd-4332-9946-538d9fe193e5'
    roleDefinitionId: roledefinitionid
  }
}
