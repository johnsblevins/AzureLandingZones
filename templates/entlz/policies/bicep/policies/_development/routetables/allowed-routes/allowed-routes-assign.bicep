param assignmentName string = 'allowed-routes'
param allowedRoutes array = [
  {
    addressPrefix: '0.0.0.0/0'
    nextHopType: 'VirtualAppliance'
    nextHopIPAddress: '10.0.0.4'
  }
  {
    addressPrefix: '198.0.0.0/24'
    nextHopType: 'Internet'
    nextHopIPAddress: ''
  }
]
param notScopes array = []
param policyDefinitionId string = '/subscriptions/f86eed1f-a251-4b29-a8b3-98089b46ce6c/providers/Microsoft.Authorization/policyDefinitions/allowed-routes'
param effect string = 'Deny'

targetScope='resourceGroup'

resource policyassignment 'Microsoft.Authorization/policyAssignments@2021-06-01'={
  name: assignmentName
  location: resourceGroup().location
  properties: {
    description: 'Allowed routes on route tables.'
    displayName: assignmentName
    enforcementMode: 'Default'
    nonComplianceMessages: [
      {
        message: 'The following routes are allowed for Route Tables: ${allowedRoutes}'
      }      
    ]
    notScopes: notScopes
    policyDefinitionId: policyDefinitionId
    parameters: {
      allowedRoutes:{
        value: allowedRoutes
      }
      effect:{
        value: effect
      }
    }
  }
}
