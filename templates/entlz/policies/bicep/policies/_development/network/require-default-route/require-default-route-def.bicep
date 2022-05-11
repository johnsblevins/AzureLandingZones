targetScope='subscription'

var mode = 'All'

resource policyDefintion 'Microsoft.Authorization/policyDefinitions@2021-06-01'={
  name: 'require-default-route'
  properties: {
    description: 'A Default Route is required on Route Tables.'
    displayName: 'require-default-route'
    metadata: {
      version: '1.0'
      category: 'Network'
    }
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
            anyOf: [
              {            
                field: 'type'
                equals: 'Microsoft.Network/routeTables'            
              }
            ] 
          }
          {
            count: {
              field: 'Microsoft.Network/routeTables/routes[*]'
              where: {
                field: 'Microsoft.Network/routeTables/routes[*].addressPrefix'
                equals: '0.0.0.0/0'
              }
            }
            notequals: 1 
          }
        ]                 
      }
      then: {
        effect: '[parameters(\'effect\')]'        
      }
    }
  }
}

output id string = policyDefintion.id
