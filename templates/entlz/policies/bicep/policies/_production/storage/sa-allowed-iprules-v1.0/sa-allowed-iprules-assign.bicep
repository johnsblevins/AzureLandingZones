param assignmentName string = 'sa-allowed-iprules'
param allowedAddressRanges array = [
  '196.0.0.0/24'
]
param notScopes array = []
param policyDefinitionId string
param effect string = 'Deny'

targetScope='resourceGroup'

resource policyassignment 'Microsoft.Authorization/policyAssignments@2021-06-01'={
  name: assignmentName
  location: resourceGroup().location
  properties: {
    description: 'IP Rules in Storage Account Firewalls are restricted.'
    displayName: assignmentName
    enforcementMode: 'Default'
    nonComplianceMessages: [
      {
        message: 'IP Rules in Storage Account Firewalls are restricted.'
      }      
    ]
    notScopes: notScopes
    policyDefinitionId: policyDefinitionId
    parameters: {
      allowedAddressRanges:{
        value: allowedAddressRanges
      }
      effect:{
        value: effect
      }
    }
  }
}
