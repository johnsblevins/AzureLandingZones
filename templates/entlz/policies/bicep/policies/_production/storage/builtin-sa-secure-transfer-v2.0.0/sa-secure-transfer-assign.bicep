param assignmentName string = 'sa-secure-transfer'
param notScopes array = []
param policyDefinitionId string
param effect string = 'Deny'

targetScope='resourceGroup'

resource policyassignment 'Microsoft.Authorization/policyAssignments@2021-06-01'={
  name: assignmentName
  location: resourceGroup().location
  properties: {
    description: 'Secure transfer to storage accounts should be enabled.'
    displayName: assignmentName
    enforcementMode: 'Default'
    nonComplianceMessages: [
      {
        message: 'Secure transfer to storage accounts should be enabled.'
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
