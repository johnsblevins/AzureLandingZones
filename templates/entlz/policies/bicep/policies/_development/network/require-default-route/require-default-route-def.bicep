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
            field: 'type'
            equals: 'Microsoft.Network/routeTables'            
          }
          {
            field: 'Microsoft.Network/routeTables/routes[*].addressPrefix'
            notequals: '0.0.0.0/0'
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
