param assignmentName string = 'activity-logs-to-loga'
param notScopes array = []
param policyDefinitionId string
param logAnalytics string
param effect string
param location string

targetScope='subscription'

resource policyassignment 'Microsoft.Authorization/policyAssignments@2021-06-01'={
  name: assignmentName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    description: 'Configure Azure Activity logs to stream to specified Log Analytics workspace.'
    displayName: assignmentName
    enforcementMode: 'Default'
    nonComplianceMessages: [
      {
        message: 'Azure Activity logs must stream to a specified Log Analytics workspace.'
      }      
    ]
    notScopes: notScopes
    policyDefinitionId: policyDefinitionId
    parameters: {
      logAnalytics:{
        value: logAnalytics
      }
      effect: {
        value: effect
      }
    }
  }
}
