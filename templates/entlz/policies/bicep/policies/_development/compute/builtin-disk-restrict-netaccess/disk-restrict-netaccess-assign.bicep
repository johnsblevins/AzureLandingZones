param assignmentName string = 'disk-restrict-netaccess'
param notScopes array = []
param policyDefinitionId string
param effect string

targetScope='resourceGroup'

resource policyassignment 'Microsoft.Authorization/policyAssignments@2021-06-01'={
  name: assignmentName
  location: resourceGroup().location
  properties: {
    description: 'Allowed resource types.'
    displayName: assignmentName
    enforcementMode: 'Default'
    nonComplianceMessages: [
      {
        message: 'Only approved resource types are allowed.'
      }      
    ]
    notScopes: notScopes
    policyDefinitionId: policyDefinitionId
    parameters: {
      effect: {
        value: effect
      }
    }
  }
}
