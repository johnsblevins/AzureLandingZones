targetScope='subscription'

var mode = 'All'

resource disallowed_builtin_roles 'Microsoft.Authorization/policyDefinitions@2021-06-01'={
  name: 'disallowed-builtin-roles-policy'
  properties: {
    description: 'Disallowed Builtin Roles can\'t be assigned.'
    displayName: 'disallowed-builtin-roles-policy'
    mode: mode
    policyType: 'Custom'
    parameters: {
      disallowedBuiltinRoles:{
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
            field: 'Microsoft.Authorization/roleAssignments/roleDefinitionId'
            notin: '[parameters(\'disallowedBuiltinRoles\')]'
          }
        ]
      }
      then: {
        effect: '[parameters(\'effect\')]'
      }
    }
  }
}

output id string = disallowed_builtin_roles.id
