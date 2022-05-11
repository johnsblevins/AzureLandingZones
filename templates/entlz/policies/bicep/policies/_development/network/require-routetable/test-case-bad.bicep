targetScope='resourceGroup'

resource badvnet 'Microsoft.Network/virtualNetworks@2021-03-01'={
  name: 'bad-vnet'
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
        }
      }
    ]
  }
}
