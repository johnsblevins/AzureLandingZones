targetScope='resourceGroup'

resource nic 'Microsoft.Network/networkInterfaces@2021-03-01' ={
  name: 'goodnic'
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
    enableIPForwarding: false
    networkSecurityGroup: {
      id: nsg.id
    }
  }
} 

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-03-01' = {
  name: 'goodnsg'
  location: resourceGroup().location
  properties: {
    securityRules:[
      {
        name: 'first_rule'
        properties: {
          description: 'This is the first rule'
          protocol: 'Tcp'
          sourcePortRange: '23-45'
          destinationPortRange: '46-56'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 123
          direction: 'Inbound'
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
  name: 'goodvnet'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '196.0.0.0/16'        
      ]       
    }
    subnets: [
      {
        name: 'subnet'
        properties: {
          addressPrefix: '196.0.0.0/24'          
        }
      }
    ]
  }
}
