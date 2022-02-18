param adminUsername string = 'azureadmin'
@secure() 
param adminPassword string

targetScope='resourceGroup'

resource onpremvnet 'Microsoft.Network/virtualNetworks@2020-11-01'={
  name: 'onpremvnet'
  location: resourceGroup().location
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

resource onpremvnetgwpip 'Microsoft.Network/publicIPAddresses@2020-11-01'={
  name: 'onpremvnetgwpip'
  location: resourceGroup().location
   sku: {
     name: 'Basic'
   }
   properties: {
      publicIPAllocationMethod: 'Dynamic'       
   }
}

resource onpremvnetgw 'Microsoft.Network/virtualNetworkGateways@2020-11-01'={
  name: 'onpremvnetgw'
  location: resourceGroup().location    
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

resource cloudhubvnet 'Microsoft.Network/virtualNetworks@2020-11-01'={
  name: 'cloudhubvnet'
  location: resourceGroup().location
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
            id: hubrt.id
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

resource privatednsakscloudhub 'Microsoft.Network/privateDnsZones@2018-09-01'={
  name: 'cloudhub.privatelink.usgovvirginia.cx.aks.containerservice.azure.us'
  location: resourceGroup().location
}
 
resource privatednsakscloudhubvnetlink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01'={
  name: 'privatednsakscloudhubvnetlink'
  location: resourceGroup().location
  parent: privatednsakscloudhub
  properties: {
    registrationEnabled: true
     virtualNetwork: {
       id: cloudhubvnet.id
     }
  }
}

resource cloudhubvnetgwpip 'Microsoft.Network/publicIPAddresses@2020-11-01'={
  name: 'cloudhubvnetgwpip'
  location: resourceGroup().location
   sku: {
     name: 'Basic'
   }
   properties: {
      publicIPAllocationMethod: 'Dynamic'       
   }
}

resource cloudhubvnetgw 'Microsoft.Network/virtualNetworkGateways@2020-11-01'={
  name: 'cloudhubvnetgw'
  location: resourceGroup().location    
  properties: {
    gatewayType: 'Vpn'
    gatewayDefaultSite: {
      id: onpremlocalnetworkgateway.id
    }
    enableDnsForwarding: true
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

resource cloudspokevnet 'Microsoft.Network/virtualNetworks@2020-11-01'={
  name: 'cloudspokevnet'
  location: resourceGroup().location
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
            id: spokert.id
          }
        }        
      }
    ]    
  }
}

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

resource spokert 'Microsoft.Network/routeTables@2021-02-01' = {
  name: 'spokert'
  location: resourceGroup().location
  properties: {
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


resource hubrt 'Microsoft.Network/routeTables@2021-02-01' = {
  name: 'hubrt'
  location: resourceGroup().location
  properties: {
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


resource onpremlocalnetworkgateway 'Microsoft.Network/localNetworkGateways@2021-02-01'= {
  name: 'onpremlocalnetworkgateway'
  location: resourceGroup().location
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
  location: resourceGroup().location
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
  location: resourceGroup().location
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
  location: resourceGroup().location
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

resource dcpip 'Microsoft.Network/publicIPAddresses@2020-11-01'={
  name: 'dcpip'
  location: resourceGroup().location
  sku: {
    name: 'Basic'
  }
  properties: {
    publicIPAllocationMethod: 'Static'    
  }
}

resource dcnic 'Microsoft.Network/networkInterfaces@2020-11-01'={
  name: 'dcnic'
  location: resourceGroup().location
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
            id: dcpip.id
          }          
        }
      }
    ]
  }
}

resource dc 'Microsoft.Compute/virtualMachines@2021-03-01'={
  name: 'dc01'
  location: resourceGroup().location
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
          id: dcnic.id
        }
      ]
    }
    osProfile: {
      adminUsername: adminUsername
      adminPassword: adminPassword
      computerName: 'dc01'
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
/*
resource dccse 'Microsoft.Compute/virtualMachines/extensions@2021-07-01' ={
  name: 'dccse'
  parent: dc
  location: resourceGroup().location
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

resource bastionnic 'Microsoft.Network/networkInterfaces@2020-11-01'={
  name: 'bastionnic'
  location: resourceGroup().location
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
  location: resourceGroup().location
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



//resource bastiondomainjoin 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
//  name: 'bastiondomainjoin'
//  location: resourceGroup().location
//  parent: bastion
//  properties: {
//    autoUpgradeMinorVersion: true
//    publisher: 'Microsoft.Compute'
//    type: 'JsonADDomainExtension'
//    typeHandlerVersion: '1.3'
//    settings: {
//      name: 'ad.contoso.com'
//      user: 'ad\\${adminUsername}'
//      restart: true      
//    }
//    protectedSettings: {
//      Password: 'password123!!'
//    }
//  }
//}


resource hubbastionnic 'Microsoft.Network/networkInterfaces@2020-11-01'={
  name: 'hubbastionnic'
  location: resourceGroup().location
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

resource hubbastion 'Microsoft.Compute/virtualMachines@2021-07-01'={
  name: 'hubbastion01'
  location: resourceGroup().location
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
          id: hubbastionnic.id
        }
      ]
    }
    osProfile: {
      adminUsername: adminUsername
      adminPassword: adminPassword
      computerName: 'hubbastion01'
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
