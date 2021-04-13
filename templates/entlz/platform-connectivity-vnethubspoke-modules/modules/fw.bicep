param entlzprefix string
param hubvnetid string
param hubvnetname string
param hubvnetprefix string
param fwname string
param fwtype string
param fwsubnetprefix string
param subnetname string

var location = resourceGroup().location

resource fwsubnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' existing ={
  name: subnetname
  scope: resourceGroup()
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

resource fw 'Microsoft.Network/azureFirewalls@2020-11-01'={
  location: location
  name: fwname
  dependsOn:[
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
          subnet: resourceId()
        }
      }
    ]
    sku:{
      name:'AZFW_VNet'
      tier:'Standard'
    }
  }
}
