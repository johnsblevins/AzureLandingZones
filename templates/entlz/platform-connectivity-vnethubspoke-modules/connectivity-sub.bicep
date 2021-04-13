param entlzprefix string
param hubvnetname string
param hubvnetprefix string
param gwname string
param gwtype string
param gwsubnetprefix string
param fwname string
param fwtype string
param fwsubnetprefix string
param bastionname string
param bastionsubnetprefix string

targetScope='subscription'

var location = deployment().location

resource connectivityrg 'Microsoft.Resources/resourceGroups@2020-10-01'={
  location: location
  name: '${entlzprefix}-hub-connectivity-${location}'
}

module hubvnet 'modules/hubvnet.bicep' = {
  scope: connectivityrg
  dependsOn:[
    connectivityrg
  ]
  name: '${entlzprefix}-hub-vnet-${location}'
  params:{
    hubvnetname: hubvnetname
    hubvnetprefix: hubvnetprefix    
    gwsubnetprefix: gwsubnetprefix
    fwsubnetprefix: fwsubnetprefix
    bastionsubnetprefix: bastionsubnetprefix
    fwname: fwname
    fwtype: fwtype
  }
}
