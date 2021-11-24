targetScope='subscription'

var mode = 'All'

resource disallowed_builtin_roles 'Microsoft.Authorization/policyDefinitions@2021-06-01'={
  name: 'restrict-custom-roles-policy'
  properties: {
    description: 'Restrict Custom Role Definitions.'
    displayName: 'restrict-custom-roles-policy'
    mode: mode
    policyType: 'Custom'
    parameters: {
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
            equals: 'Microsoft.Authorization/roleDefinitions'
          }
          {
            field: 'Microsoft.Authorization/roleDefinitions/type'
            equals: 'CustomRole'
          }
          {
            anyOf: [
              {
                field: 'Microsoft.Authorization/roleDefinitions/permissions[*].actions[*]'
                contains: 'Microsoft.Authorization'
              }              
              {
                field: 'Microsoft.Authorization/roleDefinitions/permissions.actions[*]'
                contains: 'Microsoft.Authorization'
              }     
              {
                field: 'Microsoft.Authorization/roleDefinitions/permissions[*].actions[*]'
                contains: 'Microsoft.Blueprint'
              }              
              {
                field: 'Microsoft.Authorization/roleDefinitions/permissions.actions[*]'
                contains: 'Microsoft.Blueprint'
              }    
              {
                field: 'Microsoft.Authorization/roleDefinitions/permissions[*].actions[*]'
                contains: 'Microsoft.Solutions'
              }              
              {
                field: 'Microsoft.Authorization/roleDefinitions/permissions.actions[*]'
                contains: 'Microsoft.Solutions'
              }       
              {
                field: 'Microsoft.Authorization/roleDefinitions/permissions[*].actions[*]'
                contains: 'Microsoft.Network'
              }              
              {
                field: 'Microsoft.Authorization/roleDefinitions/permissions.actions[*]'
                contains: 'Microsoft.Network'
              }       
            ]
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
