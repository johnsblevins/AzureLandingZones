param assignmentName string = 'activity-logs-to-loga'
param notScopes array = []
param policyDefinitionId string
param logAnalytics string
param effect string
param location string

targetScope='subscription'

var logAnalyticsSubId = '${split(logAnalytics,'/')[2]}'

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

resource monitoringContributorAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview'={
  name: guid(subscription().id, assignmentName, '749f88d5-cbae-40b8-bcfc-e573ddc772fa')
  dependsOn: [
    policyassignment
  ]
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '749f88d5-cbae-40b8-bcfc-e573ddc772fa')
    principalType: 'ServicePrincipal'
    principalId: policyassignment.identity.principalId    
  }
}

module LogAnalyticsContributorAssignment 'sub-role-assignment.bicep'={
  name: 'Deploy-LogA-Contributor-Role-Assignment'
  scope: subscription(logAnalyticsSubId)
  dependsOn: [
    policyassignment
  ]
  params: {
    principalId:  policyassignment.identity.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '92aaf0da-9dab-42b6-94a3-d43ce8d16293')
  }
}
