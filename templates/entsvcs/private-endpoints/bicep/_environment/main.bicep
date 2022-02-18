param adminUsername string = 'azureadmin'
@secure() 
param adminPassword string
param location string = resourceGroup().location
param deploymentId string
targetScope='resourceGroup'


// Route Tables
module spokert 'routetable.bicep' = {
  name: 'spokert-deploy-${deploymentId}'
  params: {
    location: location
    rtname: 'spokert'
    routes: [
      {
        name: 'DefaultRoute'
        properties: {
          nextHopType: 'VirtualNetworkGateway'
          addressPrefix: '0.0.0.0/0'          
        }        
      }
      {
        name: 'McrMicrosoftCom'
        properties: {
          nextHopType: 'Internet'
          addressPrefix: '204.79.197.219/32'          
        }        
      }      
    ]
  }
}

module hubrt 'routetable.bicep' = {
  name: 'hubrt-deploy-${deploymentId}'
  params: {
    location: location
    rtname: 'hubrt'
    routes: [
      {
        name: 'DefaultRoute'
        properties: {
          nextHopType: 'VirtualNetworkGateway'
          addressPrefix: '0.0.0.0/0'          
        }        
      }
    ]
  }
}


// Virtual Networks
///// VNETs
resource onpremvnet 'Microsoft.Network/virtualNetworks@2020-11-01'={
  name: 'onpremvnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes:[
        '10.0.0.0/16'  
      ]            
    }
    dhcpOptions: {
      dnsServers: [
        '10.0.0.4'
      ]
    }
    subnets: [
      {
        name: 'default'
        properties:{
          addressPrefix: '10.0.0.0/24'
        }        
      }
      {
        name: 'GatewaySubnet'
        properties:{
          addressPrefix: '10.0.1.0/24'          
        }        
      }
    ]
  }
}

resource cloudhubvnet 'Microsoft.Network/virtualNetworks@2020-11-01'={
  name: 'cloudhubvnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes:[
        '10.1.0.0/16'  
      ]            
    }
    dhcpOptions: {
      dnsServers: [
        '10.0.0.4'
      ]
    }
    subnets: [
      {
        name: 'default'
        properties:{
          addressPrefix: '10.1.0.0/24'
          routeTable: {
            id: hubrt.outputs.id
          }
        }                
      }
      {
        name: 'GatewaySubnet'
        properties:{
          addressPrefix: '10.1.1.0/24'
        }        
      }
    ]
  }  
}

resource cloudspokevnet 'Microsoft.Network/virtualNetworks@2020-11-01'={
  name: 'cloudspokevnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes:[
        '10.2.0.0/16'  
      ]            
    }
    dhcpOptions: {
      dnsServers: [
        '10.0.0.4'
      ]
    }
    subnets: [
      {
        name: 'default'
        properties:{
          addressPrefix: '10.2.0.0/24'
          routeTable: {
            id: spokert.outputs.id
          }
        }        
      }
    ]    
  }
}

///// VNET Peers
resource spoketohubpeer 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-11-01'={
  name: 'spoke-to-hub-peer'
  parent: cloudspokevnet
  dependsOn: [
    cloudhubvnetgw
    onpremvnetgw
  ]
  properties: {
    allowForwardedTraffic: false
    allowVirtualNetworkAccess: true
    useRemoteGateways: true
    remoteVirtualNetwork: {
      id: cloudhubvnet.id    
    }    
  }
}

resource hubtospoke 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-11-01'={
  name: 'hub-to-spoke-peer'
  parent: cloudhubvnet
  dependsOn: [
    cloudhubvnetgw
    onpremvnetgw
  ]
  properties: {
    allowForwardedTraffic: true
    allowVirtualNetworkAccess: true
    allowGatewayTransit: true
    remoteVirtualNetwork: {
      id: cloudspokevnet.id    
    }    
  }
}


// PIPs
resource onpremvnetgwpip 'Microsoft.Network/publicIPAddresses@2020-11-01'={
  name: 'onpremvnetgwpip'
  location: location
   sku: {
     name: 'Basic'
   }
   properties: {
      publicIPAllocationMethod: 'Dynamic'       
   }
}

resource cloudhubvnetgwpip 'Microsoft.Network/publicIPAddresses@2020-11-01'={
  name: 'cloudhubvnetgwpip'
  location: location
   sku: {
     name: 'Basic'
   }
   properties: {
      publicIPAllocationMethod: 'Dynamic'       
   }
}


// VNET GWs
resource onpremvnetgw 'Microsoft.Network/virtualNetworkGateways@2020-11-01'={
  name: 'onpremvnetgw'
  location: location    
  properties: {
    gatewayType: 'Vpn'
    sku: {
      name: 'VpnGw1'
      tier: 'VpnGw1'
    }
    vpnType: 'RouteBased'
    ipConfigurations: [
      {
        name: 'onpremvnetgwconfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: onpremvnetgwpip.id
          }
          subnet: {
            id: '${onpremvnet.id}/subnets/GatewaySubnet'
          }           
        }
      }
    ]
  }
}

resource cloudhubvnetgw 'Microsoft.Network/virtualNetworkGateways@2020-11-01'={
  name: 'cloudhubvnetgw'
  location: location    
  properties: {
    gatewayType: 'Vpn'
    gatewayDefaultSite: {
      id: onpremlocalnetworkgateway.id
    }
    sku: {
      name: 'VpnGw1'
      tier: 'VpnGw1'
    }
    vpnType: 'RouteBased'
    ipConfigurations: [
      {
        name: 'cloudhubvnetgwconfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: cloudhubvnetgwpip.id
          }
          subnet: {
            id: '${cloudhubvnet.id}/subnets/GatewaySubnet'
          }           
        }
      }
    ]
  }
}

resource onpremlocalnetworkgateway 'Microsoft.Network/localNetworkGateways@2021-02-01'= {
  name: 'onpremlocalnetworkgateway'
  location: location
  dependsOn: [
    onpremvnetgw
  ]
  properties:{
    gatewayIpAddress: onpremvnetgwpip.properties.ipAddress
    localNetworkAddressSpace: {
      addressPrefixes:[
        '10.0.0.0/16'        
      ]
    }
  }
}

resource cloudhublocalnetworkgateway 'Microsoft.Network/localNetworkGateways@2021-02-01'= {
  name: 'cloudhublocalnetworkgateway'
  location: location
  dependsOn: [
    cloudhubvnetgw
  ]
  properties:{    
    gatewayIpAddress: cloudhubvnetgwpip.properties.ipAddress
    localNetworkAddressSpace: {
      addressPrefixes:[
        '10.1.0.0/16'        
        '10.2.0.0/16'        
      ]
    }
  }
}

resource onpremtohubvpnconn 'Microsoft.Network/connections@2021-03-01' = {
  name: 'onpremtohubvpnconn'  
  location: location
  properties: {
    sharedKey: adminPassword
    localNetworkGateway2: {
      id: cloudhublocalnetworkgateway.id
    }
    virtualNetworkGateway1: {      
      id: onpremvnetgw.id
    }    
    connectionType: 'IPsec'
  }
}

resource hubvpntoonpremconn 'Microsoft.Network/connections@2020-11-01' = {
  name: 'hubvpntoonpremconn'  
  location: location
  properties: {
    sharedKey: adminPassword
    localNetworkGateway2: {
      id: onpremlocalnetworkgateway.id
    }
    virtualNetworkGateway1: {
      id: cloudhubvnetgw.id
    }
    connectionType: 'IPsec'
  }
}


// DNS Zones
//// Private DNS Zones
resource privatednsakscloudhub 'Microsoft.Network/privateDnsZones@2018-09-01'={
  name: 'cloudhub.privatelink.usgovvirginia.cx.aks.containerservice.azure.us'
  location: 'global'
}
 
//// Private DNS Zone VNET Links
resource privatednsakscloudhubvnetlink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01'={
  name: 'privatednsakscloudhubvnetlink'
  location: 'global'
  parent: privatednsakscloudhub
  properties: {
    registrationEnabled: true
     virtualNetwork: {
       id: cloudhubvnet.id
     }
  }
}



// Onprem DNS Server
//// PIP
resource onpremdnspip 'Microsoft.Network/publicIPAddresses@2020-11-01'={
  name: 'onpremdnspip'
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    publicIPAllocationMethod: 'Static'    
  }
}

//// NIC
resource onpremdnsnic 'Microsoft.Network/networkInterfaces@2020-11-01'={
  name: 'onpremdnsnic'
  location: location
  properties: {
    dnsSettings: {
      dnsServers: [
        '10.0.0.4'
        '168.63.129.16'
      ]
    }
    ipConfigurations: [
      {
        name: 'ipconfig'
        properties: {
          primary: true
          subnet: {
            id: '${onpremvnet.id}/subnets/default'
          }
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '10.0.0.4'
          publicIPAddress: {
            id: onpremdnspip.id
          }          
        }
      }
    ]
  }
}

//// VM
resource onpremdns 'Microsoft.Compute/virtualMachines@2021-03-01'={
  name: 'onpremdns01'
  location: location
  dependsOn: [
    hubvpntoonpremconn
    onpremtohubvpnconn
  ]
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2s_v3'
    }
    networkProfile:{
      networkInterfaces:[
        {
          id: onpremdnsnic.id
        }
      ]
    }
    osProfile: {
      adminUsername: adminUsername
      adminPassword: adminPassword
      computerName: 'onpremdns01'
      windowsConfiguration: {
        enableAutomaticUpdates: true
        provisionVMAgent: true
      }
    }
    licenseType: 'Windows_Server'
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
      }
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
    }
    diagnosticsProfile: {
      bootDiagnostics:{
        enabled: true        
      }      
    }
  }
}

//// Custom Script Extension

resource onpremdnscse 'Microsoft.Compute/virtualMachines/extensions@2021-07-01' ={
  name: 'onpremdnscse'
  parent: onpremdns
  location: location
  properties:{
    autoUpgradeMinorVersion: true
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    protectedSettings: {
      commandToExecute: 'powershell -command "& {Install-WindowsFeature -name DNS -IncludeManagementTools;}";'
    }
  }
}

// Cloud Hub DNS Proxy Server
resource cloudhubdnsnic 'Microsoft.Network/networkInterfaces@2020-11-01'={
  name: 'cloudhubdnsnic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig'
        properties: {
          primary: true
          subnet: {
            id: '${cloudhubvnet.id}/subnets/default'
          }
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '10.1.0.254'
        }
      }
    ]
  }
}

resource cloudhubdns 'Microsoft.Compute/virtualMachines@2021-07-01'={
  name: 'cloudhubdns01'
  location: location
  dependsOn: [
    hubvpntoonpremconn
    onpremtohubvpnconn
    //dccse
  ]
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2s_v3'
    }
    networkProfile:{
      networkInterfaces:[
        {
          id: cloudhubdnsnic.id
        }
      ]
    }
    osProfile: {
      adminUsername: adminUsername
      adminPassword: adminPassword
      computerName: 'cloudhubdns01'
      windowsConfiguration: {
        enableAutomaticUpdates: true
        provisionVMAgent: true
      }
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
      }
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
    }    
    diagnosticsProfile: {
      bootDiagnostics:{
        enabled: true        
      }      
    }
  }
}

resource cloudhubdnscse 'Microsoft.Compute/virtualMachines/extensions@2021-07-01' ={
  name: 'cloudhubdnscse'
  parent: cloudhubdns
  location: location
  properties:{
    autoUpgradeMinorVersion: true
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    protectedSettings: {
      commandToExecute: 'powershell -command "& {Install-WindowsFeature -name DNS -IncludeManagementTools;}";'
    }
  }
}

// Cloud Spoke Bastion Server

resource bastionnic 'Microsoft.Network/networkInterfaces@2020-11-01'={
  name: 'bastionnic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig'
        properties: {
          primary: true
          subnet: {
            id: '${cloudspokevnet.id}/subnets/default'
          }
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '10.2.0.254'
        }
      }
    ]
  }
}

resource bastion 'Microsoft.Compute/virtualMachines@2021-07-01'={
  name: 'bastion01'
  location: location
  dependsOn: [
    hubvpntoonpremconn
    onpremtohubvpnconn
    //dccse
  ]
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2s_v3'
    }
    networkProfile:{
      networkInterfaces:[
        {
          id: bastionnic.id
        }
      ]
    }
    osProfile: {
      adminUsername: adminUsername
      adminPassword: adminPassword
      computerName: 'bastion01'
      windowsConfiguration: {
        enableAutomaticUpdates: true
        provisionVMAgent: true
      }
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
      }
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
    }    
    diagnosticsProfile: {
      bootDiagnostics:{
        enabled: true        
      }      
    }
  }
}

/*
resource dccse 'Microsoft.Compute/virtualMachines/extensions@2021-07-01' ={
  name: 'dccse'
  parent: dc
  location: location
  properties:{
    autoUpgradeMinorVersion: true
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    protectedSettings: {
      commandToExecute: 'powershell -command "& {Install-WindowsFeature -name AD-Domain-Services -IncludeManagementTools; Install-ADDSForest -DomainName ad.contoso.com -DomainNetBIOSName AD -InstallDNS -SafeModeAdministratorPassword (convertto-securestring -string ""password123!!"" -AsPlainText -force) -force; shutdown -r -t 0; }";'
    }
  }
}
*/

// Log Analytics Workspaces
module hubloga 'loga.bicep' = {
  name: 'hubloga-deploy-${deploymentId}'
  params: {
    logaworkspacename: 'hublogaworkspace'
    location: location
  }
}
