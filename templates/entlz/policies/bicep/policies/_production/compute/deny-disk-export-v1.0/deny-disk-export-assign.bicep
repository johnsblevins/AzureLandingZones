param assignmentName string = 'deny-disk-export'
param notScopes array = []
param policyDefinitionId string
param effect string = 'Modify'

targetScope='resourceGroup'

resource policyassignment 'Microsoft.Authorization/policyAssignments@2021-06-01'={
  name: assignmentName
  location: resourceGroup().location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    description: 'Managed Disks cannot be exported.'
    displayName: assignmentName
    enforcementMode: 'Default'
    nonComplianceMessages: [
      {
        message: 'Managed Disks Cannot be exported.'
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
