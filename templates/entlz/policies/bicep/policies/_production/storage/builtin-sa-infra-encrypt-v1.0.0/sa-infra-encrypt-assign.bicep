param assignmentName string = 'sa-infra-encrypt'
param notScopes array = []
param policyDefinitionId string
param effect string = 'Deny'

targetScope='resourceGroup'

resource policyassignment 'Microsoft.Authorization/policyAssignments@2021-06-01'={
  name: assignmentName
  location: resourceGroup().location
  properties: {
    description: 'Storage accounts should have infrastructure encryption.'
    displayName: assignmentName
    enforcementMode: 'Default'
    nonComplianceMessages: [
      {
        message: 'Storage accounts should have infrastructure encryption.'
      }      
    ]
    notScopes: notScopes
    policyDefinitionId: policyDefinitionId
    parameters: {
      effect:{
        value: effect
      }
    }
  }
}
