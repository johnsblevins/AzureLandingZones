targetScope='subscription'

var mode = 'All'

resource sa_allowed_iprules 'Microsoft.Authorization/policyDefinitions@2021-06-01'={
  name: 'nic-require-nsg'
  properties: {
    description: 'Require NSG on NICs.'
    displayName: 'nic-require-nsg'
    mode: mode
    metadata: {
      version: '1.0'
      category: 'Network'
    }
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
            equals: 'Microsoft.Network/networkInterfaces'
          }
          {
            field: 'Microsoft.Network/networkInterfaces/networkSecurityGroup'
            exists: 'false' 
          }
        ]
      }
      then: {
        effect: '[parameters(\'effect\')]'
      }
    }
  }
}

output id string = sa_allowed_iprules.id
