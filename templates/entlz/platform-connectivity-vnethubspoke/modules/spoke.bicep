param spokevnetname string
param spokevnetprefix string
param managementsubnetprefix string
param hubvnetname string
param hubvnetsub string
param hubvnetrgname string
param spoketohubpeername string
param hubtospokepeername string

resource hubvnetrg 'Microsoft.Resources/resourceGroups@2020-10-01' existing={
  name: hubvnetrgname
  scope: subscription('${hubvnetsub}')
}

resource hubvnet 'Microsoft.Network/virtualNetworks@2020-08-01' existing={
  name: hubvnetname
  scope: resourceGroup('${hubvnetsub}','${hubvnetrg}')
}

resource spokevnet 'Microsoft.Network/virtualNetworks@2020-08-01'= {
  name: spokevnetname
  location: resourceGroup().location
  properties:{
    addressSpace: {
      addressPrefixes: [
        spokevnetprefix   
      ]
    }    
    subnets: [
      {
        name: 'management'
        properties:{
          addressPrefix: managementsubnetprefix     
        }
      }
    ]
  }  
}

module spoketohubpeer 'peering.bicep'={
  name: spoketohubpeername
  scope: resourceGroup()
  params:{
    dstVNETName: hubvnet.name
    dstVNETRG: hubvnetrg.name
    dstVNETSub: hubvnetsub
    peerName: spoketohubpeername
    srcVNETName: spokevnetname
    allowForwardedTraffic: true
    allowGatewayTransit: true
    allowVirtualNetworkAccess: false
    useRemoteGateways: true
  }
}

module hubtospokepeer 'peering.bicep'={
  name: hubtospokepeername
  scope: hubvnetrg
  params:{
    dstVNETName: spokevnet.name
    dstVNETRG: resourceGroup().name
    dstVNETSub: subscription().subscriptionId
    peerName: hubtospokepeername
    srcVNETName: hubvnetname
    allowForwardedTraffic: false
    allowGatewayTransit: true
    allowVirtualNetworkAccess: true
    useRemoteGateways: false
  }
}

output spokevnetid string = spokevnet.id
output hubvnetid string = hubvnet.id
