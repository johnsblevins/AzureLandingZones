param assignmentName string = 'allowed-vnet-peers'
param allowedVnetPeers array = [
  '/subscriptions/f86eed1f-a251-4b29-a8b3-98089b46ce6c/resourceGroups/ansible/providers/Microsoft.Network/virtualNetworks/ansible-vnet'
]
param notScopes array = []
param policyDefinitionId string = '/subscriptions/f86eed1f-a251-4b29-a8b3-98089b46ce6c/providers/Microsoft.Authorization/policyDefinitions/allowed-vnet-peers'
param effect string = 'Deny'

targetScope='resourceGroup'

resource policyassignment 'Microsoft.Authorization/policyAssignments@2021-06-01'={
  name: assignmentName
  location: resourceGroup().location
  properties: {
    description: 'Specifies the allowed peers for Virtual Networks.'
    displayName: assignmentName
    enforcementMode: 'Default'
    nonComplianceMessages: [
      {
        message: 'Allowed peers for Virtual Networks are restricted.'
      }      
    ]
    notScopes: notScopes
    policyDefinitionId: policyDefinitionId
    parameters: {
      allowedVnetPeers:{
        value: allowedVnetPeers
      }
      effect:{
        value: effect
      }
    }
  }
}
