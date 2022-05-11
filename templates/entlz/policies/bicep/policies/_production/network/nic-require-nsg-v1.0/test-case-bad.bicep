targetScope='resourceGroup'

resource nic 'Microsoft.Network/networkInterfaces@2021-03-01' ={
  name: 'badnic'
  location: resourceGroup().location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig'
        properties:{
          subnet: {            
            id: subnet.id
          }
        }
      }
    ]
  }
} 

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-03-01' existing = {
  parent: vnet
  name: 'subnet'
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-03-01' = {
  name: 'badvnet'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '200.0.0.0/16'        
      ]       
    }
    subnets: [
      {
        name: 'subnet'
        properties: {
          addressPrefix: '200.0.0.0/24'          
        }
      }
    ]
  }
}
