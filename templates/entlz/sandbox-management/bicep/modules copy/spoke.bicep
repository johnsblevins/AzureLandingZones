param appsubnetprefix string
param spokevnetname string
param spokevnetprefix string
param datasubnetprefix string
param managementsubnetprefix string
param hubvnetname string
param hubvnetsubid string
param hubvnetrgname string
param spoketohubpeername string
param hubtospokepeername string
param subrtname string
param subnsgname string
param fwip string
param websubnetprefix string

var location=resourceGroup().location

resource hubvnetrg 'Microsoft.Resources/resourceGroups@2020-10-01' existing={
  name: hubvnetrgname
  scope: subscription('${hubvnetsubid}')
}

resource hubvnet 'Microsoft.Network/virtualNetworks@2020-08-01' existing={
  name: hubvnetname
  scope: resourceGroup('${hubvnetsubid}','${hubvnetrg}')
}

resource spokert 'Microsoft.Network/routeTables@2020-11-01'={
  name: subrtname
  location: location
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
  name: subnsgname
  location: location
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
      {
        name: 'web'
        properties:{
          addressPrefix: websubnetprefix     
          routeTable:{
            id: spokert.id
          }
          networkSecurityGroup:{
            id: spokensg.id
          }
        }
      }
      {
        name: 'app'
        properties:{
          addressPrefix: appsubnetprefix     
          routeTable:{
            id: spokert.id
          }
          networkSecurityGroup:{
            id: spokensg.id
          }
        }
      }
      {
        name: 'data'
        properties:{
          addressPrefix: datasubnetprefix     
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
    dstVNETSub: hubvnetsubid
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

resource spokertlock 'Microsoft.Authorization/locks@2016-09-01'={
  name: 'routetablelock'
  dependsOn:[
    spoketohubpeer
    hubtospokepeer
  ]
  properties: {
    level: 'ReadOnly'    
  }
  scope: spokert
}

resource spokensglock 'Microsoft.Authorization/locks@2016-09-01'={
  name: 'nsglock'
  dependsOn:[
    spoketohubpeer
    hubtospokepeer
  ]
  properties: {
    level: 'ReadOnly'    
  }
  scope: spokensg
}

output spokevnetid string = spokevnet.id
output hubvnetid string = hubvnet.id
