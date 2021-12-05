targetScope='subscription'

var mode = 'All'

resource allowed_routes 'Microsoft.Authorization/policyDefinitions@2021-06-01'={
  name: 'allowed-routes'
  properties: {
    description: 'Specified the allowed routes for route tables'
    displayName: 'allowed-routes'
    metadata: {
      version: '1.0'
      category: 'Network'
    }
    mode: mode
    policyType: 'Custom'
    parameters: {
      allowedRoutes:{
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
        anyOf: [
          {
            allOf: [
              {            
                field: 'type'
                equals: 'Microsoft.Network/routeTables'            
              }
              {
                count: {
                  field: 'Microsoft.Network/routeTables/routes[*]'
                  where: {
                    count: {
                      value: '[parameters(\'allowedRoutes\')]'
                      name: 'allowedroute'
                      where: {
                        allOf: [              
                          {
                            field: 'Microsoft.Network/routeTables/routes[*].addressPrefix'
                            equals: '[current(\'allowedRoute\').addressPrefix]'
                          }
                          {
                            anyOf: [
                              {
                                allOf: [
                                  {
                                    field: 'Microsoft.Network/routeTables/routes[*].nextHopType'
                                    equals: 'VirtualAppliance'
                                  }
                                  {
                                    field: 'Microsoft.Network/routeTables/routes[*].nextHopIpAddress'
                                    equals: '[current(\'allowedRoute\').nextHopIpAddress]'
                                  }
                                ]
                              }
                              {
                                allOf: [
                                  {
                                    field: 'Microsoft.Network/routeTables/routes[*].nextHopType'
                                    notequals: 'VirtualAppliance'
                                  }
                                  {
                                    field: 'Microsoft.Network/routeTables/routes[*].nextHopType'
                                    equals: '[current(\'allowedRoute\').nextHopType]'                         
                                  }   
                                ]
                              }                                                 
                            ]
                          }
                        ]  
                      }                
                    }
                    greater: 0
                  }              
                }
                less: '[length(field(\'Microsoft.Network/routeTables/routes\'))]'
              }
            ]        
          }
          {
            allOf: [
              {
                field: 'type'
                equals: 'Microsoft.Network/routeTables/routes'
              }
              {
                count: {
                  value: '[parameters(\'allowedRoutes\')]'
                  name: 'allowedroute'
                  where: {
                    allOf: [              
                      {
                        field: 'Microsoft.Network/routeTables/routes/addressPrefix'
                        equals: '[current(\'allowedRoute\').addressPrefix]'
                      }
                      {
                        anyOf: [
                          {
                            allOf: [
                              {
                                field: 'Microsoft.Network/routeTables/routes/nextHopType'
                                equals: 'VirtualAppliance'
                              }
                              {
                                field: 'Microsoft.Network/routeTables/routes/nextHopIpAddress'
                                equals: '[current(\'allowedRoute\').nextHopIpAddress]'
                              }
                            ]
                          }
                          {
                            allOf: [
                              {
                                field: 'Microsoft.Network/routeTables/routes/nextHopType'
                                notequals: 'VirtualAppliance'
                              }
                              {                            
                                field: 'Microsoft.Network/routeTables/routes/nextHopType'
                                equals: '[current(\'allowedRoute\').nextHopType]'                         
                              }
                            ]
                          }                      
                        ]
                      }
                    ]  
                  }                
                }
                equals: 0
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
