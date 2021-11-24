targetScope='subscription'

var mode = 'All'

resource policyDefintion 'Microsoft.Authorization/policyDefinitions@2021-06-01'={
  name: 'require-routetable'
  properties: {
    description: 'A Route Table is required on Subnets.'
    displayName: 'require-routetable'
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
        anyOf: [
          {
            allOf: [
              {
                field: 'type'
                equals: 'Microsoft.Network/virtualNetworks'            
              }
              {
                field: 'Microsoft.Network/virtualNetworks/subnets[*].routeTable'
                exists: 'false'
              }
            ]
          }
          {
            allOf: [
              { 
                field: 'type'
                equals: 'Microsoft.Network/virtualNetworks/subnets'            
              }              
              {
                field: 'Microsoft.Network/virtualNetworks/subnets/routeTable'
                exists: 'false'
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

output id string = policyDefintion.id
