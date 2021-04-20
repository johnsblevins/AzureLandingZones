param spokevnetname string
param spokevnetprefix string
param managementsubnetprefix string
param hubvnetname string
param hubvnetsub string
param hubvnetrg string
param spoketohubpeername string
param hubtospokepeername string

resource hubvnet 'Microsoft.Network/virtualNetworks@2020-08-01' existing={
  name: '${hubvnetname}'
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
  resource spoketohubpeer 'virtualNetworkPeerings@2020-11-01'={
    name: spoketohubpeername
    properties:{
      allowForwardedTraffic:true      
      allowVirtualNetworkAccess:true
      useRemoteGateways:true
      remoteVirtualNetwork:{
        id: hubvnet.id
      }      
    }
  }
}

output spokevnetid string = spokevnet.id
