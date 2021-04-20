param spokevnetname string
param spokevnetprefix string
param managementsubnetprefix string
param hubvnetname string
param hubvnetsub string
param hubvnetrgname string
param spoketohubpeername string
param hubtospokepeername string
param spokevnetrtname string
param fwip string

resource hubvnetrg 'Microsoft.Resources/resourceGroups@2020-10-01' existing={
  name: hubvnetrgname
  scope: subscription('${hubvnetsub}')
}

resource hubvnet 'Microsoft.Network/virtualNetworks@2020-08-01' existing={
  name: hubvnetname
  scope: resourceGroup('${hubvnetsub}','${hubvnetrg}')
}

resource spokert 'Microsoft.Network/routeTables@2020-11-01'={
  name: spokevnetrtname
  location: resourceGroup().location
  properties:{
    disableBgpRoutePropagation: true
    routes:[
      {
        name: 'defaultroute'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopIpAddress: fwip
          nextHopType: 'VirtualAppliance'
        }
      }
    ]
  }
}

resource spokertlock 'Microsoft.Authorization/locks@2016-09-01'={
  name: 'routetablelock'
  dependsOn:[
    spokert
  ]
  properties: {
    level: 'ReadOnly'    
  }
  scope: spokert
}

resource spokevnet 'Microsoft.Network/virtualNetworks@2020-08-01'= {
  name: spokevnetname
  dependsOn:[
    spokert
    spokertlock
  ]
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
          routeTable:{
            id: spokevnetrtname
          }
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
