targetScope='subscription'

var mode = 'All'

resource sa_allowed_iprules 'Microsoft.Authorization/policyDefinitions@2021-06-01'={
  name: 'kv-allowed-iprules'
  properties: {
    description: 'IP Rules in Key Vault Firewalls are restricted.'
    displayName: 'kv-allowed-iprules'
    mode: mode
    metadata: {
      version: '1.0'
      category: 'Key Vault'
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
      allowedAddressRanges: {
        type: 'Array'
        metadata: {
          description: 'The list of allowed IP address ranges (Allowed internet address ranges can be provided using CIDR notation in the form 10.0.0.0/24 or as individual IP addresses like 10.0.0.4)'
          displayName: 'Address Range'
        }
        defaultValue: []
      }
    }
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.KeyVault/vaults'
          }
          {
            count: {
              field: 'Microsoft.KeyVault/vaults/networkAcls.ipRules[*]'
              where:{
                field: 'Microsoft.KeyVault/vaults/networkAcls.ipRules[*].value'
                notin: '[parameters(\'allowedAddressRanges\')]'
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

output id string = sa_allowed_iprules.id
