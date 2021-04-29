param bastionname string
param bastionsubnetname string
param bastionsubnetprefix string
param environment string
param ergwname string
param fwip string
param fwmanagementrtname string
param fwmanagementsubnetname string
param fwmanagementsubnetprefix string
param fwname string
param fwpolicyname string
param fwrtname string
param fwsubnetname string
param fwsubnetprefix string
param fwtype string
param gwrtname string
param gwsubnetname string
param gwsubnetprefix string
param gwtier string
param gwtype string
param hubmanagementrtname string
param hubmanagementsubnetname string
param hubmanagementsubnetprefix string
param hubvnetname string
param hubvnetprefix string
param identityvnetprefix string
param location string
param logaworkspaceid string
param managementvnetprefix string
param securityvnetprefix string
param vpngwname string

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
    disableBgpRoutePropagation: false
    routes:[
    {
        name: 'defaultroute'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualNetworkGateway'     
        }        
      }
    ]
  }
}

resource hubmanagementrt 'Microsoft.Network/routeTables@2020-11-01' = {
  location: location
  name: hubmanagementrtname
  properties:{
    disableBgpRoutePropagation: false
    routes:[
    {
        name: 'defaultroute'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: fwip     
        }        
      }
    ]
  }
}

resource gwrt 'Microsoft.Network/routeTables@2020-11-01' = {
  location: location
  name: gwrtname
  properties:{
    disableBgpRoutePropagation: false
    routes:[
      {
        name: 'managementsubnet'
        properties: {
          addressPrefix: hubmanagementsubnetprefix
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: fwip     
        }        
      }
      {
        name: 'identityvnet'
        properties: {
          addressPrefix: identityvnetprefix
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: fwip     
        }        
      }
      {
        name: 'securityvnet'
        properties: {
          addressPrefix: securityvnetprefix
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: fwip     
        }        
      }
      {
        name: 'managementvnet'
        properties: {
          addressPrefix: managementvnetprefix
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: fwip     
        }        
      }
    ]
  }
}

resource hubvnet 'Microsoft.Network/virtualNetworks@2020-08-01'= {
  name: hubvnetname
  location: location
  dependsOn:[
    fwrt
    fwmanagementrt
    hubmanagementrt
    gwrt
  ]
  properties:{
    addressSpace: {
      addressPrefixes: [
        hubvnetprefix   
      ]
    }  
    subnets:[
      {        
        name: gwsubnetname        
        properties:{
          addressPrefix: gwsubnetprefix
          routeTable:{
            id: gwrt.id
          }
        }
      }
      {
        name: fwmanagementsubnetname        
        properties:{
          addressPrefix: fwmanagementsubnetprefix
          routeTable: {
            id: fwmanagementrt.id
          }
        }
      }
      {
        name: fwsubnetname
        properties:{
          addressPrefix: fwsubnetprefix
          routeTable: {
            id: fwrt.id
          }
        }
      }
      {
        name: hubmanagementsubnetname
        properties:{
          addressPrefix: hubmanagementsubnetprefix
          routeTable:{
            id: hubmanagementrt.id
          }
        }
      }
      {
        name: bastionsubnetname
        properties:{
          addressPrefix: bastionsubnetprefix
        }
      }
    ]      
  }
}

resource fwpip 'Microsoft.Network/publicIPAddresses@2020-11-01'={
  location: location
  name: '${fwname}-pip'
  sku: {
    name:'Standard'
  }
  zones:[
    '1'
    '2'
    '3'
  ]
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
  zones:[
    '1'
    '2'
    '3'
  ]
  properties:{
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'    
  }
}

resource fwpolicy 'Microsoft.Network/firewallPolicies@2020-11-01'={
  location: location
  name: fwpolicyname
  properties:{
    threatIntelMode:'Deny'
    insights:{
      isEnabled: true
      logAnalyticsResources:{
        defaultWorkspaceId: {
          id: logaworkspaceid
        }        
      }
      retentionDays: 360      
    }
    sku:{
      tier: fwtype
    }    
  }
}

resource fw 'Microsoft.Network/azureFirewalls@2020-11-01'= if( !(empty(fwsubnetprefix)) && !(empty(fwmanagementsubnetprefix)) && ( fwtype=='Standard' || fwtype=='Premium') ){
  location: location
  name: fwname
  dependsOn:[
    hubvnet
    fwpip
    fwpolicy
  ]
  zones:[
    '1'
    '2'
    '3'
  ]
  properties:{
    ipConfigurations: [
      {
        name: '${fwname}-ipconfiguration'
        properties:{
          publicIPAddress: {
            id: fwpip.id
          }
          subnet: {
            id: '${hubvnet.id}/subnets/${fwsubnetname}'
          }
        }
      }
    ]
    managementIpConfiguration: {
      name: '${fwname}-managementipconfiguration'
      properties:{
        publicIPAddress: {
          id: fwmanagementpip.id
        }
        subnet:{
          id: '${hubvnet.id}/subnets/${fwmanagementsubnetname}'
        }
      }
    }
    threatIntelMode: 'Deny'    
    sku:{
      name:'AZFW_VNet'
      tier: fwtype
    }
    firewallPolicy:{
      id: fwpolicy.id
    }
  }
}

resource vpngwpip1 'Microsoft.Network/publicIPAddresses@2020-11-01'=  if( !(empty(gwsubnetprefix)) && (gwtype=='Vpn') ){
  location: location
  name: '${vpngwname}-pip-1'
  sku: {
    name:'Standard'
  }
  zones:[
    '1'
    '2'
    '3'
  ]
  properties:{
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'    
  }
}

resource vpngwpip2 'Microsoft.Network/publicIPAddresses@2020-11-01'= if( !(empty(gwsubnetprefix)) &&  (gwtype=='Vpn') ){
  location: location
  name: '${vpngwname}-pip-2'
  sku: {
    name:'Standard'
  }
  zones:[
    '1'
    '2'
    '3'
  ]
  properties:{
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'    
  }
}

resource ergwpip 'Microsoft.Network/publicIPAddresses@2020-11-01'=  if( !(empty(gwsubnetprefix)) && (gwtype=='ExpressRoute') ){
  location: location
  name: '${ergwname}-pip'
  sku: {
    name:'Standard'
  }
  zones:[
    '1'
    '2'
    '3'
  ]
  properties:{
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'    
  }
}

resource bastionpip 'Microsoft.Network/publicIPAddresses@2020-11-01'= if( !(empty(bastionsubnetprefix))){
  name: '${bastionname}-pip'
  sku:{
    name:'Standard'
  }
  zones:[
    '1'
    '2'
    '3'
  ]
  properties:{
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }  
}

resource vpngw 'Microsoft.Network/virtualNetworkGateways@2020-11-01' = if( !(empty(gwsubnetprefix)) &&  (gwtype=='Vpn') ) {
  location: location
  name: vpngwname
  dependsOn:[
    hubvnet
    vpngwpip1
    vpngwpip2
  ]
  properties:{
    gatewayType: gwtype
    sku: {
      name: gwtier
      tier: gwtier
    }
    activeActive: true
    ipConfigurations:[
      {
        name: '${vpngwname}-ipconfig1'
        properties:{
          subnet: {
            id: '${hubvnet.id}/subnets/${gwsubnetname}'
          }
          publicIPAddress: {
            id: vpngwpip1.id
          }          
        }
      }
      {
        name: '${vpngwname}-ipconfig2'
        properties:{
          subnet: {
            id: '${hubvnet.id}/subnets/${gwsubnetname}'
          }
          publicIPAddress: {
            id: vpngwpip2.id
          }          
        }
      }
    ]
    vpnType: 'RouteBased'    
  }
}

resource ergw 'Microsoft.Network/virtualNetworkGateways@2020-11-01' = if( !(empty(gwsubnetprefix)) && ( gwtype=='ExpressRoute') ) {
  location: location
  name: ergwname
  dependsOn:[
    hubvnet
    ergwpip
  ]
  properties:{
    gatewayType: gwtype
    sku: {
      name: gwtier
      tier: gwtier
    }
    ipConfigurations:[
      {
        name: '${ergwname}-ipconfig1'
        properties:{
          subnet: {
            id: '${hubvnet.id}/subnets/${gwsubnetname}'
          }
          publicIPAddress: {
            id: ergwpip.id
          }          
        }
      }
    ]
    vpnType: 'RouteBased'    
  }
}

resource bastion 'Microsoft.Network/bastionHosts@2020-11-01'= {
  name: bastionname
  location: location
  properties:{
    ipConfigurations: [
      {
        name: '${bastionname}-ipconfig1'
        properties:{
          publicIPAddress: bastionpip
          subnet:{
            id: '${hubvnet.id}/subnets/${bastionsubnetname}'
          }
        }
      }
    ]
  }
}
