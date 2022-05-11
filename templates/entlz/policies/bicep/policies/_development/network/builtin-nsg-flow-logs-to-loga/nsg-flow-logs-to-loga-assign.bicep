param assignmentName string = 'nsg-flow-logs-to-loga'
param notScopes array = []
param policyDefinitionId string
param effect string
param nsgRegion string
param storageId string
param timeInterval string
param workspaceResourceId string
param networkwatcherName string

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
      effect: effect
    }
  }
}
