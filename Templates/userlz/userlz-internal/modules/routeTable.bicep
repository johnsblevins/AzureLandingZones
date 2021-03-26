param rtName string
param firewallIP string

resource routeTable 'Microsoft.Network/routeTables@2020-08-01'={
  name: '${rtName}'
  location: resourceGroup().location
  properties:{
    routes:[
      {
        name: 'DefaultRoute'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopIpAddress: firewallIP
          nextHopType: 'VirtualAppliance'
        }
      }
    ]
  }
}

output rtId string = routeTable.id
