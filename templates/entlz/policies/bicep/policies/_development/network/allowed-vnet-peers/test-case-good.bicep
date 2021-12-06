targetScope='resourceGroup'

resource vnet 'Microsoft.Network/virtualNetworks@2021-03-01' = {
  name: 'goodvnet'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '196.0.0.0/16'        
      ]       
    }
    virtualNetworkPeerings: [
      {
        name: 'peer-to-goodvnet'
        properties: {
          allowForwardedTraffic: true
          allowGatewayTransit: true
          allowVirtualNetworkAccess: true
          remoteVirtualNetwork:{
            id: '/subscriptions/f86eed1f-a251-4b29-a8b3-98089b46ce6c/resourceGroups/ansible/providers/Microsoft.Network/virtualNetworks/ansible-vnet'
          }
        }
      }
    ]    
  }
}