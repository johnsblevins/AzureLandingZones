param assignmentName string = 'kv-restrict-netaccess'
param notScopes array = []
param policyDefinitionId string
param effect string

targetScope='resourceGroup'

resource policyassignment 'Microsoft.Authorization/policyAssignments@2021-06-01'={
  name: assignmentName
  location: resourceGroup().location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    description: 'Key Vaults should restrict network access.'
    displayName: assignmentName
    enforcementMode: 'Default'
    nonComplianceMessages: [
      {
        message: 'Key Vaults should restrict network access.'
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
