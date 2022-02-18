param aksname string = 'aks-private-001'
param dnsprefix string = 'testdatafabric-dns'
param agentpoolname string = 'test'
param vnetSubnetID string
param adminUsername string = 'adn'
param aksClusterSshPublicKey string
param userassignedidentityname string
param location string = resourceGroup().location
param networkPlugin string = 'azure'
param loadBalancerSku string = 'standard'
param serviceCidr string = '10.2.0.0/24'
param dnsServiceIP string = '10.2.0.10'
param dockerBridgeCidr string = '172.17.0.1/16'
param outboundType string = 'userDefinedRouting'
param aksClusterSkuName string = 'Basic'
param aksClusterSkuTier string = 'Free'
param aksClusterIdentityType string = 'SystemAssigned'
param aksClusterKubernetesVersion string = '1.20.9'

targetScope='resourceGroup'

resource aksprivatecluster 'Microsoft.ContainerService/managedClusters@2022-01-02-preview'={
  name: aksname
  location: location
  sku: {
    name: aksClusterSkuName
    tier: aksClusterSkuTier
  }
  identity: {
     type: aksClusterIdentityType
  }
  properties: {
    kubernetesVersion: aksClusterKubernetesVersion
    dnsPrefix: dnsprefix
    agentPoolProfiles: [
      {
        name: agentpoolname
        count: 3
        vmSize: 'standard_d4s_v4'
        osDiskSizeGB: 30
        osDiskType: 'Managed'
        kubeletDiskType: 'OS'
        vnetSubnetID: vnetSubnetID
        maxPods: 10
        type: 'VirtualMachineScaleSets'
        enableAutoScaling: false
        orchestratorVersion: '1.20.9'
        enableNodePublicIP: false
        mode: 'System'
        enableEncryptionAtHost: false
        enableUltraSSD: false
        osType: 'Linux'
        osSKU: 'Ubuntu'
        enableFIPS: false        
      }      
    ]
    linuxProfile: {
      adminUsername: adminUsername
      ssh: {
        publicKeys: [
          {
            keyData: aksClusterSshPublicKey
          }
        ]
      }
    }
    servicePrincipalProfile: {
      clientId: 'msi'
    }
    nodeResourceGroup: 'MC_Data-Fabric_${aksname}_usgovvirginia'
    enableRBAC: true
    networkProfile: {
      networkPlugin: networkPlugin
      loadBalancerSku: loadBalancerSku
      serviceCidr: serviceCidr
      dnsServiceIP: dnsServiceIP
      dockerBridgeCidr: dockerBridgeCidr
      outboundType: outboundType
    }
  }
}

resource userassignedidentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30'={
  name: userassignedidentityname
  location: location
}
