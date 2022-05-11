targetScope='resourceGroup'


resource rtbad 'Microsoft.Network/routeTables@2021-03-01'={
  name: 'rt-bad'
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
      {
        name: 'bad-route'
        properties: {
          nextHopType: 'Internet'          
          addressPrefix: '196.0.0.0/24'
        }
      }
    ]
  }
}
