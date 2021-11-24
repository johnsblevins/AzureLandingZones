targetScope='resourceGroup'

resource goodroleassignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview'= {
  name: 'User RIghts Administrator-Assignment'
  properties: {
    principalId: '36805b3f-52fb-4452-ba0b-085de56bf023'
    roleDefinitionId: '18d7d88d-d35e-4fb5-a5c3-7773c20a72d9' //User Access Administrator
  }
}
