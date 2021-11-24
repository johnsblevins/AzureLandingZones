targetScope='resourceGroup'

resource badroleassignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview'= {
  name: 'Owner-Assignment'
  properties: {
    principalId: '36805b3f-52fb-4452-ba0b-085de56bf023'
    roleDefinitionId: '8e3af657-a8ff-443c-a75c-2fe8c4bcb635' // Owner
  }
}
