param hubvnetname string
param hubvnetprefix string
param gwsubnetprefix string
param fwsubnetprefix string
param bastionsubnetprefix string

resource hubvnet 'Microsoft.Network/virtualNetworks@2020-08-01'= {
  name: hubvnetname
  location: resourceGroup().location
  properties:{
    addressSpace: {
      addressPrefixes: [
        hubvnetprefix   
      ]
    }    
    subnets: [
      {
        name: 'GatewaySubnet'
        properties:{
            addressPrefix: gwsubnetprefix     
        }
      }
      {
        name: 'AzureFirewallSubnet'
        properties:{
          addressPrefix: fwsubnetprefix     
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties:{
          addressPrefix: bastionsubnetprefix     
        }
      }
    ]            
  }
}

output hubvnetid string = hubvnet.id
