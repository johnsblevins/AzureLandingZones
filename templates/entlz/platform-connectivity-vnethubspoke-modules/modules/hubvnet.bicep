param hubvnetname string
param hubvnetprefix string
param gwsubnetprefix string
param fwsubnetprefix string
param bastionsubnetprefix string
//param managementsubnetprefix string
param fwname string
param fwtype string

var location= resourceGroup().location
var gwsubnetname = 'GatewaySubnet'
var fwsubnetname = 'AzureFirewallSubnet'
var bastionsubnetname = 'AzureBastionSubnet'

resource hubvnet 'Microsoft.Network/virtualNetworks@2020-08-01'= {
  name: hubvnetname
  location: location
  properties:{
    addressSpace: {
      addressPrefixes: [
        hubvnetprefix   
      ]
    }        
  }
}

resource gwsubnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = if(!(empty(gwsubnetprefix))) {
  parent: hubvnet
  name: gwsubnetname
  dependsOn: [
    hubvnet
  ]
  properties:{
    addressPrefix: gwsubnetprefix
  }
}

resource fwsubnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = if(!(empty(fwsubnetprefix))) {
  parent: hubvnet
  name: fwsubnetname
  dependsOn: [
    hubvnet
    gwsubnet
  ]
  properties:{
    addressPrefix: fwsubnetprefix
  }
}

resource bastionsubnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = if(!(empty(bastionsubnetprefix))) {
  parent: hubvnet
  name: bastionsubnetname
  dependsOn: [
    hubvnet
    fwsubnet
  ]
  properties:{
    addressPrefix: bastionsubnetprefix
  }
}
/*
resource fwpip 'Microsoft.Network/publicIPAddresses@2020-11-01'={
  location: location
  name: '${fwname}-pip'
  sku: {
    name:'Standard'
  }
  properties:{
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'    
  }
}

resource fw 'Microsoft.Network/azureFirewalls@2020-11-01'={
  location: location
  name: fwname
  dependsOn:[
    hubvnet
    fwpip
  ]
  zones:[
    '1'
    '2'
    '3'
  ]
  properties:{
    ipConfigurations: [
      {
        properties:{
          publicIPAddress: fwpip
          subnet: {
            id: '${hubvnet.id}/subnets/${fwsubnetname}'
          }
        }
      }
    ]
    sku:{
      name:'AZFW_VNet'
      tier:'Standard'
    }
  }
}

*/


