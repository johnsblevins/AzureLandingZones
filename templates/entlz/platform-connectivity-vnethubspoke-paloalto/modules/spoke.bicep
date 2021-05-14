param spokevnetname string
param spokevnetprefix string
param managementsubnetprefix string
param hubvnetname string
param hubvnetsub string
param hubvnetrgname string
param spoketohubpeername string
param hubtospokepeername string
param spokevnetrtname string
param spokevnetnsgname string
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


resource spokensg 'Microsoft.Network/networkSecurityGroups@2020-08-01' = {
  name: spokevnetnsgname
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

resource spokevnet 'Microsoft.Network/virtualNetworks@2020-08-01'= {
  name: spokevnetname
  dependsOn:[
    spokert
    spokensg
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
            id: spokert.id
          }
          networkSecurityGroup:{
            id: spokensg.id
          }
        }
      }
    ]
  }  
}

module spoketohubpeer 'peering.bicep'={
  name: spoketohubpeername
  dependsOn:[
    spokevnet
  ]
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
  dependsOn:[
    spokevnet
  ]
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
