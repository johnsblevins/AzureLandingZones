param assignmentName string = 'allowed-resource-types'
param notScopes array = []
param policyDefinitionId string
param listOfResourceTypesAllowed array = [
  'microsoft.compute/availabilitysets'
  'microsoft.compute/virtualmachines'
  'microsoft.compute/virtualmachines/extensions'
  'microsoft.compute/disks'
  'microsoft.compute/galleries'
  'microsoft.compute/snapshots'
  'microsoft.compute/images'
  'microsoft.keyvault/vaults'
  'microsoft.keyvault/secrets'
  'microsoft.keyvault/accesspolicies'
  'microsoft.keyvault/operations'
  'microsoft.keyvault/checknameavailability'
  'microsoft.keyvault/deletedvaults'
  'microsoft.keyvault/vaults'
  'microsoft.network/applicationsecuritygroups'
  'microsoft.network/dnsoperationresults'
  'microsoft.network/dnsoperationstatuses'
  'microsoft.network/dnszones'
  'microsoft.network/dnszones'
  'microsoft.network/networkinterfaces'
  'microsoft.network/networksecuritygroups'
  'microsoft.network/routetables'
  'microsoft.network/virtualnetworks'
  'microsoft.operationalinsights/workspaces'
  'microsoft.operationalinsights/workspaces/tables'
  'microsoft.operationalinsights/workspaces/query'
  'microsoft.operationalinsights/solutions'
  'microsoft.storage/storageaccounts'
  'microsoft.storage/storageaccounts/blobservices'
]


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
      listOfResourceTypesAllowed:{
        value: listOfResourceTypesAllowed
      }
    }
  }
}
