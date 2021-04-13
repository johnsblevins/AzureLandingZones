param hubvnetname string
param hubvnetprefix string
param gwtype string = 'Vpn'
param gwsubnetprefix string
param fwsubnetprefix string
param fwmanagementsubnetprefix string
param bastionsubnetprefix string
param fwname string
param fwtype string
param environment string

var location= resourceGroup().location
var gwsubnetname = 'GatewaySubnet'
var fwsubnetname = 'AzureFirewallSubnet'
var fwrtname = '${hubvnetname}-fw-rt'
var fwmanagementsubnetname = 'AzureFirewallManagementSubnet'
var fwmanagementrtname = '${hubvnetname}-fwmanagement-rt'
var bastionsubnetname = 'AzureBastionSubnet'
var fwnexthoptype = (gwtype=='Vpn')?'VirtualNetworkGateway':'VnetLocal'

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

resource fwmanagementrt 'Microsoft.Network/routeTables@2020-11-01' = {
  location: location
  name: fwmanagementrtname
  properties:{
    disableBgpRoutePropagation: true
    routes:[
      {
        name: 'defaultroute'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'Internet'          
        }        
      }
    ]
  }
}

resource fwrt 'Microsoft.Network/routeTables@2020-11-01' = {
  location: location
  name: fwrtname
  properties:{
    disableBgpRoutePropagation: true
    routes:[
      {
        name: 'azureipranges'
        properties: {
          addressPrefix: 'AzureCloud'
          nextHopType: 'VirtualNetworkGateway'
        }        
      }
      {
        name: 'defaultroute'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'Internet'     
        }        
      }
    ]
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

resource fwmanagementsubnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = if(!(empty(fwmanagementsubnetprefix))) {
  parent: hubvnet
  name: fwmanagementsubnetname
  dependsOn: [
    hubvnet
    gwsubnet
    fwmanagementrt
  ]
  properties:{
    addressPrefix: fwmanagementsubnetprefix
    routeTable: {
      id: fwmanagementrt.id
    }
  }
}

resource fwsubnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = if(!(empty(fwsubnetprefix))) {
  parent: hubvnet
  name: fwsubnetname
  dependsOn: [
    hubvnet
    fwmanagementsubnet    
    fwrt
  ]
  properties:{
    addressPrefix: fwsubnetprefix
    routeTable: {
      id: fwrt.id
    }
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

resource fwmanagementpip 'Microsoft.Network/publicIPAddresses@2020-11-01'={
  location: location
  name: '${fwname}-management-pip'
  sku: {
    name:'Standard'
  }
  properties:{
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'    
  }
}

/*
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
    managementIpConfiguration: {
      properties:{
        publicIPAddress: fwmanagementpip
        subnet:{
          id: '${hubvnet.id}/subnets/${fwmanagementsubnetname}'
        }
      }
    }
    threatIntelMode: 'Alert'    
    sku:{
      name:'AZFW_VNet'
      tier:'Standard'
    }
  }
}

*/
