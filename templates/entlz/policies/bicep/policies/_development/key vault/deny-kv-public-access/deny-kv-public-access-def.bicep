targetScope='subscription'

var mode = 'All'

resource deny_kv_public_access 'Microsoft.Authorization/policyDefinitions@2021-06-01'={
  name: 'deny-kv-public-access'
  properties: {
    description: 'KeyVaults cannot be publicly accessed.'
    displayName: 'deny-kv-public-access'
    mode: mode
    policyType: 'Custom'
    metadata: {
      category: 'KeyVault'
    }
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
        equals: 'Microsoft.KeyVault/vaults'
        }
        {
        field: 'Microsoft.KeyVault/vaults/networkAcls.defaultAction'
        notequals: 'Deny'
        }
      ]
      }
      then: {
      effect: '[parameters(\'effect\')]'
      }
    }
  }
}

output id string = deny_kv_public_access.id
