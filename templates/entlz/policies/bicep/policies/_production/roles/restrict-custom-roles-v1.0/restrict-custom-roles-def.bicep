targetScope='subscription'

var mode = 'All'

resource disallowed_builtin_roles 'Microsoft.Authorization/policyDefinitions@2021-06-01'={
  name: 'restrict-custom-roles'
  properties: {
    description: 'Restrict Custom Role Definitions.'
    displayName: 'restrict-custom-roles'
    mode: mode
    metadata: {
      version: '1.0'
      category: 'General'
    }
    policyType: 'Custom'
    parameters: {
      disallowedActionsStartsWith: {
        type: 'Array'
        defaultValue: [
          '*'
          'Microsoft.Authorization'
          'Microsoft.Network/virtualNetworks'
          'Microsoft.Network/routeTables'
          'Microsoft.Blueprint'
          'Microsoft.Solutions'
        ]
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
            equals: 'Microsoft.Authorization/roleDefinitions'
          }
          {
            anyOf: [
              {
                count: {
                  field: 'Microsoft.Authorization/roleDefinitions/permissions[*].actions[*]'
                  where: {
                    count: {
                      value: '[parameters(\'disallowedActionsStartsWith\')]'
                      name: 'disallowedActionStartsWith'
                      where: {
                        value: '[take(current(\'Microsoft.Authorization/roleDefinitions/permissions[*].actions[*]\'),length(current(\'disallowedActionStartsWith\')))]'
                        equals: '[current(\'disallowedActionStartsWith\')]'
                      }                
                    }
                    greater: 0
                  }              
                }
                greater: 0
              }
              {
                count: {
                  field: 'Microsoft.Authorization/roleDefinitions/permissions.actions[*]'
                  where: {
                    count: {
                      value: '[parameters(\'disallowedActionsStartsWith\')]'
                      name: 'disallowedActionStartsWith'
                      where: {
                        value: '[take(current(\'Microsoft.Authorization/roleDefinitions/permissions.actions[*]\'),length(current(\'disallowedActionStartsWith\')))]'
                        equals: '[current(\'disallowedActionStartsWith\')]'
                      }                
                    }
                    greater: 0
                  }              
                }
                greater: 0
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
