targetScope='resourceGroup'

resource vnet 'Microsoft.Network/virtualNetworks@2021-03-01' = {
  name: 'badvnet'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '200.0.0.0/16'        
      ]       
    }
    /*virtualNetworkPeerings: [
      {
        name: 'peer-to-badvnet'
        properties: {
          allowForwardedTraffic: false
          allowGatewayTransit: false
          allowVirtualNetworkAccess: true
          useRemoteGateways: false
          remoteVirtualNetwork:{
            id: '/subscriptions/f86eed1f-a251-4b29-a8b3-98089b46ce6c/resourceGroups/dev-hosts/providers/Microsoft.Network/virtualNetworks/dev-hosts-vnet'
          }
        }
      }
    ]*/
  }
}


resource VnetPeering1 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-05-01' = {
  parent: vnet
  name: 'peer-to-badvnet'
  properties: {
    allowForwardedTraffic: false
    allowGatewayTransit: false
    allowVirtualNetworkAccess: true
    useRemoteGateways: false
    remoteVirtualNetwork:{
      id: '/subscriptions/f86eed1f-a251-4b29-a8b3-98089b46ce6c/resourceGroups/endpoints/providers/Microsoft.Network/virtualNetworks/endpoints-vnet'
    }
  }
}

