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
