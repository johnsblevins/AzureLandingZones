targetScope='resourceGroup'

resource rtgood 'Microsoft.Network/routeTables@2021-03-01'={
  name: 'rt-good'
  location: resourceGroup().location
  properties: {
    routes:[
      {
        name: 'good-route-1'
        properties: {
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: '10.0.0.4'
          addressPrefix: '0.0.0.0/0'
        }
      }  
      {
        name: 'good-route-2'
        properties: {
          nextHopType: 'Internet'
          addressPrefix: '198.0.0.0/24'
        }
      }  
    ]
  }
}
