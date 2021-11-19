targetScope='managementGroup'
var mode = 'All'

resource allowed_routes 'Microsoft.Authorization/policyDefinitions@2021-06-01'={
  name: 'allowed-routes'
  properties: {
    description: 'Specified the allowed routes for route tables'
    displayName: 'allowed-routes'
    mode: mode
    parameters: {
      routes:{
        type: 'Array'
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
            equals: 'Microsoft.Network/routeTables'
          }
          {
            count: {
              value: '[parameters(\'routes\')]'
            }
            name: 'allowedroutes'
            where: {
              allOf: [              
                {
                  field: 'Microsoft.Network/routeTables/routes[*].addressPrefix'
                  like: '[current(\'allowedroutes\').addressPrefix]'
                }
                {
                  field: 'Microsoft.Network/routeTables/routes[*].nextHopType'
                  notequals: '[current(\'allowedroutes\').nextHopType]'
                }
                {
                  field: 'Microsoft.Network/routeTables/routes[*].nextHopIpAddress'
                  notequals: '[current(\'allowedroutes\').nextHopIpAddress]'
                }
              ]
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
