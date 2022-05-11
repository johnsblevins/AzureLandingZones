param assignmentName string = 'nic-disable-ipforward'
param notScopes array = []
param policyDefinitionId string

targetScope='resourceGroup'

resource policyassignment 'Microsoft.Authorization/policyAssignments@2021-06-01'={
  name: assignmentName
  location: resourceGroup().location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    description: 'Network interfaces should disable IP forwarding.'
    displayName: assignmentName
    enforcementMode: 'Default'
    nonComplianceMessages: [
      {
        message: 'Network interfaces should disable IP forwarding.'
      }      
    ]
    notScopes: notScopes
    policyDefinitionId: policyDefinitionId
    parameters: {
    }
  }
}
