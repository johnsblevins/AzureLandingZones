targetScope='resourceGroup'

resource rtgood 'Microsoft.Network/routeTables@2021-03-01'={
  name: 'rt-good'
  location: resourceGroup().location
  properties: {
    routes:[
      {
        name: 'good-route'
        properties: {
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: '10.0.0.4'
          addressPrefix: '0.0.0.0/0'
        }
      }    
    ]
  }
}

resource goodvnet 'Microsoft.Network/virtualNetworks@2021-03-01'={
  name: 'good-vnet'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'        
      ]
    }
    subnets: [
      {
        name: 'subnet-1'
        properties: {
          addressPrefix: '10.0.0.0/24'
          routeTable: {
            id: rtgood.id
          }          
        }        
      }
    ]
  }
}
