targetScope='resourceGroup'

resource rt 'Microsoft.Network/routeTables@2021-03-01'={
  name: 'rt3'
  location: resourceGroup().location
  properties: {
    routes: [
      {
        name: 'DefaultRoute'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: '10.0.0.4'
        }
      }
      {
        name: 'Test'
        properties: {
          addressPrefix: '198.0.0.0/24'
          nextHopType: 'Internet'
          nextHopIpAddress: ''
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
          addressPrefix: '10.0.0.0/16'    
          routeTable: {
            id: rt.id
          }  
        }        
      }
    ]
  }
}
