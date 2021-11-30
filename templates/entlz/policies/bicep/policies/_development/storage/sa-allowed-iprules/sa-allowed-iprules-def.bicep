targetScope='subscription'

var mode = 'All'

resource sa_allowed_iprules 'Microsoft.Authorization/policyDefinitions@2021-06-01'={
  name: 'sa-allowed-iprules-policy'
  properties: {
    description: 'IP Rules in Storage Account Firewalls are restricted.'
    displayName: 'sa-allowed-iprules-policy'
    mode: mode
    metadata: {
      version: '1.0'
      category: 'Storage'
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
            equals: 'Microsoft.Storage/storageAccounts'
          }
          {
            field: 'Microsoft.Storage/storageAccounts/networkAcls.ipRules[*].value'
            notin: '[parameters(\'allowedAddressRanges\')]' 
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
