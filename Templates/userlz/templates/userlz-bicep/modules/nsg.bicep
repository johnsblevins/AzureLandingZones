param nsgName string

resource nsg 'Microsoft.Network/networkSecurityGroups@2020-08-01' = {
  name: '${nsgName}'
  location: resourceGroup().location
  properties:{
    securityRules:[
      {
        name:'DefaultInboundRule'
        properties:{
          access:'Allow'
          description: 'Default NSG Rule'
          destinationAddressPrefix: '*'
          destinationPortRange:'*'
          direction: 'Inbound'
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          priority: 100
        }
      }
      {
        name:'DefaultOutboundRule'
        properties:{
          access:'Allow'
          description: 'Default NSG Rule'
          destinationAddressPrefix: '*'
          destinationPortRange:'*'
          direction: 'Outbound'
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          priority: 100
        }
      }
    ]
  }
}

output nsgID string = nsg.id
