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
param fwcount int
param publisher string
param offer string
param sku string
param version string
param vmsize string

var subnetsizes= { 
  '22': 1024
  '23': 512
  '24': 256
  '25': 128 
  '26': 64
  '27': 32
  '28': 16
  '29': 8 
}

var fwmgmtsubnetmask=split(fwmanagementsubnetprefix,'/')[1] // Get fw mgmt subnet mask ex. 24 for 10.1.4.0/24, 29 for 10.1.4.0/29
var fwmgmtsubnetoctets=split(split(fwmanagementsubnetprefix,'/')[0],'.') // Split fw mgmt subnet into octet array ex. [10,1,4,0] for 10.1.4.0/24
var fwmgmtsubnetwithoutlastoctet=concat(fwmgmtsubnetoctets[0],'.',fwmgmtsubnetoctets[1],'.',fwmgmtsubnetoctets[2],'.') // Compose fwmgmt subnet prefix without last octet ex. 10.1.4. for 10.2.4.0/24
var fwmgmtstartinglastoctet=int(fwmgmtsubnetoctets[3]) // Get starting last octet for fw mgmt subnet ex. 0 for 10.1.4.0/26, 64 for 10.1.4.64/27
var fwsubnetmask=split(fwsubnetprefix,'/')[1] // Get fw subnet mask ex. 24 for 10.1.4.0/24, 29 for 10.1.4.0/29
var fwsubnetoctets=split(split(fwsubnetprefix,'/')[0],'.') // Split fw subnet into octet array ex. [10,1,4,0] for 10.1.4.0/24
var fwsubnetwithoutlastoctet=concat(fwsubnetoctets[0],'.',fwsubnetoctets[1],'.',fwsubnetoctets[2],'.') // Compose fw subnet prefix without last octet ex. 10.1.4. for 10.2.4.0/24
var fwstartinglastoctet=int(fwsubnetoctets[3]) // Get starting last octet for fw subnet ex. 0 for 10.1.4.0/26, 64 for 10.1.4.64/27
var fwendinglastoctet=int(fwsubnetoctets[3])+subnetsizes[fwsubnetmask]-1 // Get ending last octet for fw subnet ex. 63 for 10.1.4.0/26
var fwlbip=concat(fwsubnetwithoutlastoctet,fwendinglastoctet-1)


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

resource paloaltomgmtnics 'Microsoft.Network/networkInterfaces@2020-11-01' = [for i in range(1,fwcount): {
  name: '${fwname}${i}-management-nic'
  location: location
  dependsOn: [
    hubvnet
  ]
  properties: {
    ipConfigurations:[
      {
        name: 'ipconfig-management'
        properties:{
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '${fwmgmtsubnetwithoutlastoctet}${fwmgmtstartinglastoctet+3+i}' // first ips are reserved so add 3 plus index i to start a first usable
          subnet: {
            id: '${hubvnet.id}/subnets/${fwmanagementsubnetname}'
          }
        }
      }
    ]
  }
}]

resource paloaltotrustednic1s 'Microsoft.Network/networkInterfaces@2020-11-01' = [for i in range(1,fwcount): {
  name: '${fwname}${i}-trusted-nic-1'
  location: location
  dependsOn: [
    hubvnet
  ]
  properties: {
    enableIPForwarding: true
    ipConfigurations:[
      {
        name: 'ipconfig-trusted'        
        properties:{          
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '${fwsubnetwithoutlastoctet}${fwstartinglastoctet+3+i}'  // first ips are reserved so add 3 plus index i to start a first usable
          subnet: {
            id: '${hubvnet.id}/subnets/${fwsubnetname}'
          }
        }
      }
    ]
  }
}]

resource paloaltos 'Microsoft.Compute/virtualMachines@2020-12-01' = [for i in range(1,fwcount): {
  name: '${fwname}${i}'
  location: location
  dependsOn: [
    hubvnet    
  ]
  plan:{
    name: sku
    product: offer
    publisher: publisher
  }
  zones: [
    string((i % 3) + 1)
  ]
  properties:{
    hardwareProfile:{
      vmSize: vmsize
    }
    osProfile:{
      adminUsername: 'azureadmin'
      adminPassword: 'password123!!'
      computerName: fwname
    }
    storageProfile:{
      imageReference:{
        publisher: publisher
        offer: offer
        sku: sku
        version: version
      }
      osDisk:{
        name: 'osdisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    networkProfile:{
      networkInterfaces:[
        {
          id: '${paloaltomgmtnics[i]}'
          properties:{
            primary:true         
          }
        }
        {
          id: '${paloaltotrustednic1s[i]}'
          properties:{
            primary:false
          }
        }
      ]
    }
  }
}]


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
  location: location
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
          publicIPAddress: {
            id: bastionpip.id
          }
          subnet:{
            id: '${hubvnet.id}/subnets/${bastionsubnetname}'
          }
        }
      }
    ]
  }
}
