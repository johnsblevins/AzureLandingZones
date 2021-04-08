param vmName string = 'testvm1'
param vmSize string = 'Standard_B2s'
param privateIP string = ''
param subnetName string = 'identity'
param vnetRG string = 'TSDLZ-identity-connectivity'
param vnetName string = 'TSDLZ-identity-USGovVirginia'
param adminUsername string = 'azureadmin'
param adminPassword string = 'password123!!'
param desName string = 'des'
param desRG string = 'adds'
param zone string = '1'

resource vnet 'Microsoft.Network/virtualNetworks@2020-08-01' existing={
  name: '${vnetName}'
  scope: resourceGroup('${vnetRG}')
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2020-08-01' existing={
  name: '${subnetName}'
  parent: vnet
}

resource des 'Microsoft.Compute/diskEncryptionSets@2020-09-30' existing={
  name: '${desName}'
  scope: resourceGroup('${desRG}')
}

resource nic 'Microsoft.Network/networkInterfaces@2020-08-01'={
  name: '${vmName}-nic1'
  location: resourceGroup().location
  properties:{
    ipConfigurations:[
      {
        name: '${vmName}-nic1-ipconfig1'
        properties: {
          privateIPAddress: '${privateIP}'
          privateIPAllocationMethod: empty(privateIP) ? 'Dynamic' : 'Static'
          subnet: {
            id: subnet.id
          }
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2020-12-01'={
  name: '${vmName}'
  location: '${resourceGroup().location}'
  zones:[
    zone  
  ]
  properties: {
    hardwareProfile:{
      vmSize: vmSize
    }
    networkProfile:{
      networkInterfaces:[
        {
          id: nic.id
          properties:{
            primary:true
          }
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics:{
        enabled: false
      }
    }
    osProfile:{
      adminUsername: adminUsername
      adminPassword: adminPassword
      computerName: vmName
      windowsConfiguration:{  
      }
    }
    securityProfile:{}
    storageProfile:{
      imageReference:{
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2016-Datacenter'
        version: 'latest'
      }
      osDisk:{
        name: '${vmName}-osdisk'
        createOption: 'FromImage'
        managedDisk: {
          diskEncryptionSet:{
            id: des.id
          }
        }
      }
      dataDisks:[
        {
          name: '${vmName}-datadisk-1'
          createOption: 'Empty'
          diskSizeGB: 128
          lun: 1       
          managedDisk: {
            diskEncryptionSet:{
              id: des.id
            }
          }   
        }
      ]
    }
  }
}
