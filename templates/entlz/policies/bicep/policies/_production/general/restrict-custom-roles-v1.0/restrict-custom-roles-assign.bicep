param assignmentName string = 'restrict-custom-roles'
param notScopes array = []
param policyDefinitionId string
param effect string = 'Deny'

targetScope='resourceGroup'

resource policyassignment 'Microsoft.Authorization/policyAssignments@2021-06-01'={
  name: assignmentName
  location: resourceGroup().location
  properties: {
    description: 'Restrict Custom Role Definitions.'
    displayName: assignmentName
    enforcementMode: 'Default'
    nonComplianceMessages: [
      {
        message: 'Custom Role Definitions are restricted.'
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
