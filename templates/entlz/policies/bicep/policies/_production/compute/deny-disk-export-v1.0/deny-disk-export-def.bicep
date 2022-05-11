targetScope='subscription'

var mode = 'All'

resource deny_disk_export 'Microsoft.Authorization/policyDefinitions@2021-06-01'={
  name: 'deny-disk-export'
  properties: {
    description: 'Managed Disks cannot be exported.'
    displayName: 'deny-disk-export'
    mode: mode
    policyType: 'Custom'
    metadata: {
      version: '1.0.0'
      category: 'Compute'
    }
    parameters: {     
      effect:{
        type: 'String'
        defaultValue: 'Modify'
        allowedValues: [
          'Modify'
          'Disabled'
        ]
      }
    }
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Compute/disks'
          }
        ]
      }
      then: {
        effect: '[parameters(\'effect\')]'
        details: {
          roleDefinitionIds: [
            '/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
          ]
          operations: [
            {
              operation: 'addOrReplace'
              field: 'Microsoft.Compute/disks/networkAccessPolicy'
              value: 'DenyAll'
            }
          ]
        }
      }
    }
  }
}

output id string = deny_disk_export.id
