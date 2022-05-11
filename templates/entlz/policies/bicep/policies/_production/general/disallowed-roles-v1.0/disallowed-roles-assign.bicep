param assignmentName string = 'disallowed-roles'
param disallowedRoles array = [
  '8e3af657-a8ff-443c-a75c-2fe8c4bcb635' //Owner
  'b24988ac-6180-42a0-ab88-20f7382dd24c' //Contributor
  '4d97b98b-1d4f-4787-a291-c67834d212e7' //Network Contributor
  '41077137-e803-4205-871c-5a86e6a753b4' //Blueprint Contributor
  '641177b8-a67a-45b9-a033-47bc880bb21e' //Managed Application Contributor Role
]
param notScopes array = []
param policyDefinitionId string
param effect string = 'Deny'

targetScope='resourceGroup'

resource policyassignment 'Microsoft.Authorization/policyAssignments@2021-06-01'={
  name: assignmentName
  location: resourceGroup().location
  properties: {
    description: 'Disallowed Roles can\'t be assigned.'
    displayName: assignmentName
    enforcementMode: 'Default'
    nonComplianceMessages: [
      {
        message: 'The following  Roles are Disallowed: ${disallowedRoles}'
      }      
    ]
    notScopes: notScopes
    policyDefinitionId: policyDefinitionId
    parameters: {
      disallowedRoles:{
        value: disallowedRoles
      }
      effect:{
        value: effect
      }
    }
  }
}
