targetScope='subscription'

var mode = 'All'

resource disallowed_roles 'Microsoft.Authorization/policyDefinitions@2021-06-01'={
  name: 'disallowed-roles'
  properties: {
    description: 'Disallowed Roles cannot be assigned.'
    displayName: 'disallowed-roles'
    mode: mode
    metadata: {
      version: '1.0'
      category: 'General'
    }
    policyType: 'Custom'
    parameters: {
      disallowedRoles:{
        type: 'Array'
      }
      effect:{
        type: 'String'
        defaultValue: 'Deny'
        allowedValues: [
          'Audit'
          'Deny'
          'Disabled'
        ]
      }
    }
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Authorization/roleAssignments'        
          }
          {
            count: {
              value: '[parameters(\'disallowedRoles\')]'
              name: 'disallowedRole'
              where: {
                field: 'Microsoft.Authorization/roleAssignments/roleDefinitionId'
                like: '[concat(\'*\',current(\'disallowedRole\'))]'
              }
            }
            greater: 0
          }
        ]
      }
      then: {
        effect: '[parameters(\'effect\')]'
      }
    }
  }
}

output id string = disallowed_roles.id
