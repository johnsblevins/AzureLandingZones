param srcVNETName string
param dstVNETSub string
param dstVNETName string
param dstVNETRG string
param peerName string

resource dstVNET 'Microsoft.Network/virtualNetworks@2020-08-01' existing={
  name: '${dstVNETName}'
  scope: resourceGroup('${dstVNETSub}','${dstVNETRG}')
}

resource srcVNET 'Microsoft.Network/virtualNetworks@2020-08-01' existing={
  name: '${srcVNETName}'
  resource srcToDstPeer 'virtualNetworkPeerings@2020-08-01'={
    name: '${peerName}'
    dependsOn: [
      dstVNET
    ]
    properties:{
      allowForwardedTraffic: false
      allowGatewayTransit: true
      allowVirtualNetworkAccess: true
      remoteVirtualNetwork: {
        id: dstVNET.id
      }
    }
  }
}






