param principalId string
param roleDefinitionId string

targetScope='subscription'

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-08-01-preview'={
  name: guid(subscription().id, roleDefinitionId, principalId)
  properties: {
    principalId: principalId
    roleDefinitionId: roleDefinitionId
  }
}
