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
/*
resource spoketohubpeer 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-11-01'={
  name: spoketohubpeername
  parent: spokevnet
  properties:{
    allowForwardedTraffic:true      
    allowVirtualNetworkAccess:true
    useRemoteGateways:true
    remoteVirtualNetwork:{
      id: hubvnet.id
    }      
  }
}
*/
module hubtospokepeer 'peering.bicep'={
  name: hubtospokepeername
  scope: hubvnetrg
  params:{
    dstVNETName: spokevnet.name
    dstVNETRG: resourceGroup().name
    dstVNETSub: subscription().subscriptionId
    peerName: hubtospokepeername
    srcVNETName: hubvnetname
  }
}

output spokevnetid string = spokevnet.id
output hubvnetid string = hubvnet.id
