param assignmentName string = 'require-routetable'
param notScopes array = []
param policyDefinitionId string
param effect string = 'Deny'

targetScope='resourceGroup'

resource policyassignment 'Microsoft.Authorization/policyAssignments@2021-06-01'={
  name: assignmentName
  location: resourceGroup().location
  properties: {
    description: 'A Route Table is required on Subnets.'
    displayName: assignmentName
    enforcementMode: 'Default'
    nonComplianceMessages: [
      {
        message: 'A Route Table is required on Subnets.'
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
