param adminUsername string = 'azureadmin'
@secure() 
param adminPassword string
param location string = resourceGroup().location
param deploymentId string
targetScope='resourceGroup'


// User Assigned Identities
module aksidentity 'userassignedidentity.bicep' ={
  name: 'aksidentity_deploy_${deploymentId}'
  params: {
    location: location
    userassignedidentityname: 'userassignedidentity_aks'
  }
}

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
        '10.1.0.254'
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
        '10.1.0.254'
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

resource roleassignment_cloudspokevnet 'Microsoft.Authorization/roleAssignments@2020-04-01-preview'={
  name: guid(cloudspokevnet.id, aksidentity.name, '4d97b98b-1d4f-4787-a291-c67834d212e7')
  scope: cloudspokevnet
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions','4d97b98b-1d4f-4787-a291-c67834d212e7') //Network Contributor
    principalId: aksidentity.outputs.principalId    
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

/// Private DNS Zones for AKS

  ////  Zone
resource privatednszone_usgovvirginia_aks 'Microsoft.Network/privateDnsZones@2018-09-01'={
  name: 'cloudhub.privatelink.usgovvirginia.cx.aks.containerservice.azure.us'
  location: 'global'
}
  //// Role Assignment
resource roleassignment_privatednszone_usgovvirginia_aks 'Microsoft.Authorization/roleAssignments@2020-04-01-preview'={
  name: guid(privatednszone_usgovvirginia_aks.id, aksidentity.name, 'b12aa53e-6015-4669-85d0-8515ebb3ae7f')
  scope: privatednszone_usgovvirginia_aks
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions','b12aa53e-6015-4669-85d0-8515ebb3ae7f') //Private DNS Contributor
    principalId: aksidentity.outputs.principalId    
  }
}
   //// VNET Links
resource privatedns_usgovvirginia_aks_cloudhub_vnetlink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01'={
  name: 'privatedns_usgovvirginia_aks_cloudhub_vnetlink'
  location: 'global'
  parent: privatednszone_usgovvirginia_aks
  properties: {
    registrationEnabled: false
     virtualNetwork: {
       id: cloudhubvnet.id
     }
  }
}

/// Private DNS Zone for KeyVault
  /// Zone
resource privatednszone_keyvault 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: 'privatelink.vaultcore.usgovcloudapi.net'
  location: 'global'
  properties: {
    maxNumberOfRecordSets: 25000
    maxNumberOfVirtualNetworkLinks: 1000
    maxNumberOfVirtualNetworkLinksWithRegistration: 100
  }
}
  //// VNET Links
resource privatednszone_keyvault_cloudhub_vnetlink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01'={
  name: 'privatednszone_keyvault_cloudhub_vnetlink'
  location: 'global'
  parent: privatednszone_keyvault
  properties: {
    registrationEnabled: false
     virtualNetwork: {
       id: cloudhubvnet.id
     }
  }
}

/// Private DNS Zone for Stroage Account
  /// Zone
  resource privatednszone_storageaccount_blob 'Microsoft.Network/privateDnsZones@2018-09-01' = {
    name: 'privatelink.blob.core.usgovcloudapi.net'
    location: 'global'
    properties: {
      maxNumberOfRecordSets: 25000
      maxNumberOfVirtualNetworkLinks: 1000
      maxNumberOfVirtualNetworkLinksWithRegistration: 100
    }
  }
    //// VNET Links
  resource privatednszone_storageaccount_blob_cloudhub_vnetlink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01'={
    name: 'privatednszone_storageaccount_blob_cloudhub_vnetlink'
    location: 'global'
    parent: privatednszone_storageaccount_blob
    properties: {
      registrationEnabled: false
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
  name: 'onpremdns'
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
      computerName: 'onpremdns'
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
resource clouddnsnic 'Microsoft.Network/networkInterfaces@2020-11-01'={
  name: 'clouddnsnic'
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

resource clouddns 'Microsoft.Compute/virtualMachines@2021-07-01'={
  name: 'clouddns'
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
          id: clouddnsnic.id
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
  name: 'clouddnscse'
  parent: clouddns
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

resource cloudbastionnic 'Microsoft.Network/networkInterfaces@2020-11-01'={
  name: 'cloudbastionnic'
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

resource cloudbastion 'Microsoft.Compute/virtualMachines@2021-07-01'={
  name: 'cloudbastion'
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
          id: cloudbastionnic.id
        }
      ]
    }
    osProfile: {
      adminUsername: adminUsername
      adminPassword: adminPassword
      computerName: 'cloudbastion'
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
