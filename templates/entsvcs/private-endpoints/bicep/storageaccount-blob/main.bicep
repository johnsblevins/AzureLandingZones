@description('Specifies the location for all the resources.')
param location string = resourceGroup().location

@description('Specifies the name of the virtual network hosting the virtual machine.')
param virtualNetworkName string = 'UbuntuVnet'

@description('Specifies the name of the subnet hosting the virtual machine.')
param subnetName string = 'DefaultSubnet'

@description('Specifies the globally unique name for the storage account used to store the boot diagnostics logs of the virtual machine.')
param blobStorageAccountName string = 'boot${uniqueString(resourceGroup().id)}'

@description('Specifies the base URI where artifacts required by this template are located including a trailing \'/\'')
param artifactsLocation string = deployment().properties.templateLink.uri

@description('Specifies the sasToken required to access _artifactsLocation.  When the template is deployed using the accompanying scripts, a sasToken will be automatically generated. Use the defaultValue if the staging location is not secured.')
@secure()
param artifactsLocationSasToken string = ''

@description('Specifies the script to download from the URI specified by the scriptFilePath parameter.')
param scriptFileName string = 'test-key-vault-private-endpoint.sh'

@description('Specifies the name of the key vault.')
param keyVaultName string = 'vault${uniqueString(resourceGroup().id)}'

@description('Specifies whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault.')
@allowed([
  true
  false
])
param enabledForDeployment bool = true

@description('Specifies whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys.')
@allowed([
  true
  false
])
param enabledForDiskEncryption bool = true

@description('Specifies whether Azure Resource Manager is permitted to retrieve secrets from the key vault.')
@allowed([
  true
  false
])
param enabledForTemplateDeployment bool = true

@description('Specifies whether the \'soft delete\' functionality is enabled for this key vault. If it\'s not set to any value(true or false) when creating new key vault, it will be set to true by default. Once set to true, it cannot be reverted to false.')
@allowed([
  true
  false
])
param enableSoftDelete bool = true

@description('Specifies the softDelete data retention days. It accepts >=7 and <=90.')
param softDeleteRetentionInDays int = 90

@description('Controls how data actions are authorized. When true, the key vault will use Role Based Access Control (RBAC) for authorization of data actions, and the access policies specified in vault properties will be ignored (warning: this is a preview feature). When false, the key vault will use the access policies specified in vault properties, and any policy stored on Azure Resource Manager will be ignored. If null or not specified, the vault is created with the default value of false. Note that management actions are always authorized with RBAC.')
@allowed([
  true
  false
])
param enableRbacAuthorization bool = false

@description('Specifies the Azure Active Directory tenant ID that should be used for authenticating requests to the key vault. Get it by using Get-AzSubscription cmdlet.')
param tenantId string = subscription().tenantId

@description('Specifies the permissions to keys in the vault. Valid values are: all, encrypt, decrypt, wrapKey, unwrapKey, sign, verify, get, list, create, update, import, delete, backup, restore, recover, and purge.')
param keysPermissions array = [
  'get'
  'create'
  'delete'
  'list'
  'update'
  'import'
  'backup'
  'restore'
  'recover'
]

@description('Specifies the permissions to secrets in the vault. Valid values are: all, get, list, set, delete, backup, restore, recover, and purge.')
param secretsPermissions array = [
  'get'
  'list'
  'set'
  'delete'
  'backup'
  'restore'
  'recover'
]

@description('Specifies the permissions to certificates in the vault. Valid values are: all, get, list, set, delete, managecontacts, getissuers, listissuers, setissuers, deleteissuers, manageissuers, backup, and recover.')
param certificatesPermissions array = [
  'get'
  'list'
  'delete'
  'create'
  'import'
  'update'
  'managecontacts'
  'getissuers'
  'listissuers'
  'setissuers'
  'deleteissuers'
  'manageissuers'
  'backup'
  'recover'
]

@description('Specifies whether the key vault is a standard vault or a premium vault.')
@allowed([
  'Standard'
  'Premium'
])
param skuName string = 'Standard'

@description('Specifies the name of the private link to key vault.')
param keyVaultPrivateEndpointName string = 'KeyVaultPrivateEndpoint'

@description('Specifies the name of the private link to the boot diagnostics storage account.')
param blobStorageAccountPrivateEndpointName string = 'BlobStorageAccountPrivateEndpoint'

var subnetId = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetName)
var scriptFileUri = uri(artifactsLocation, 'scripts/${scriptFileName}${artifactsLocationSasToken}')
var keyVaultId = keyVaultName_resource.id
var blobStorageAccountId = blobStorageAccountName_resource.id
var keyVaultPublicDNSZoneForwarder = ((toLower(environment().name) == 'azureusgovernment') ? '.vaultcore.usgovcloudapi.net' : '.vaultcore.azure.net')
var blobPublicDNSZoneForwarder = '.blob.${environment().suffixes.storage}'
var keyVaultPrivateDnsZoneName_var = 'privatelink${keyVaultPublicDNSZoneForwarder}'
var blobPrivateDnsZoneName_var = 'privatelink${blobPublicDNSZoneForwarder}'
var keyVaultPrivateDnsZoneId = keyVaultPrivateDnsZoneName.id
var blobPrivateDnsZoneId = blobPrivateDnsZoneName.id
var keyVaultPrivateEndpointId = keyVaultPrivateEndpointName_resource.id
var blobStorageAccountPrivateEndpointId = blobStorageAccountPrivateEndpointName_resource.id
var keyVaultPrivateEndpointGroupName = 'vault'
var blobStorageAccountPrivateEndpointGroupName = 'blob'
var keyVaultPrivateDnsZoneGroupName_var = '${keyVaultPrivateEndpointName}/${keyVaultPrivateEndpointGroupName}PrivateDnsZoneGroup'
var blobPrivateDnsZoneGroupName_var = '${blobStorageAccountPrivateEndpointName}/${blobStorageAccountPrivateEndpointGroupName}PrivateDnsZoneGroup'
var keyVaultPrivateDnsZoneGroupId = resourceId('Microsoft.Network/privateEndpoints/privateDnsZoneGroups', keyVaultPrivateEndpointName, '${keyVaultPrivateEndpointGroupName}PrivateDnsZoneGroup')

resource keyVaultName_resource 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: keyVaultName
  location: location
  properties: {
    tenantId: tenantId
    sku: {
      name: skuName
      family: 'A'
    }
    enabledForDeployment: enabledForDeployment
    enabledForTemplateDeployment: enabledForTemplateDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    enableSoftDelete: enableSoftDelete
    softDeleteRetentionInDays: softDeleteRetentionInDays
    enableRbacAuthorization: enableRbacAuthorization
    accessPolicies: [
      {
        tenantId: tenantId
        objectId: reference(vmId, '2019-12-01', 'Full').identity.principalId
        permissions: {
          keys: keysPermissions
          secrets: secretsPermissions
          certificates: certificatesPermissions
        }
      }
    ]
  }
  dependsOn: [
    vmId
  ]
}

resource blobStorageAccountName_resource 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: blobStorageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

resource keyVaultPrivateDnsZoneName 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: keyVaultPrivateDnsZoneName_var
  location: 'global'
  properties: {
    maxNumberOfRecordSets: 25000
    maxNumberOfVirtualNetworkLinks: 1000
    maxNumberOfVirtualNetworkLinksWithRegistration: 100
  }
}

resource blobPrivateDnsZoneName 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: blobPrivateDnsZoneName_var
  location: 'global'
  properties: {
    maxNumberOfRecordSets: 25000
    maxNumberOfVirtualNetworkLinks: 1000
    maxNumberOfVirtualNetworkLinksWithRegistration: 100
  }
}

resource keyVaultPrivateDnsZoneName_link_to_virtualNetworkName 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  parent: keyVaultPrivateDnsZoneName
  name: 'link_to_${toLower(virtualNetworkName)}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
  dependsOn: [
    keyVaultPrivateDnsZoneId
    vnetId
  ]
}

resource blobPrivateDnsZoneName_link_to_virtualNetworkName 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  parent: blobPrivateDnsZoneName
  name: 'link_to_${toLower(virtualNetworkName)}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
  dependsOn: [
    blobPrivateDnsZoneId
    vnetId
  ]
}

resource keyVaultPrivateEndpointName_resource 'Microsoft.Network/privateEndpoints@2020-04-01' = {
  name: keyVaultPrivateEndpointName
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: keyVaultPrivateEndpointName
        properties: {
          privateLinkServiceId: keyVaultId
          groupIds: [
            keyVaultPrivateEndpointGroupName
          ]
        }
      }
    ]
    subnet: {
      id: subnetId
    }
    customDnsConfigs: [
      {
        fqdn: concat(keyVaultName, keyVaultPublicDNSZoneForwarder)
      }
    ]
  }
  dependsOn: [
    vnetId
    keyVaultId
  ]
}

resource blobStorageAccountPrivateEndpointName_resource 'Microsoft.Network/privateEndpoints@2020-04-01' = {
  name: blobStorageAccountPrivateEndpointName
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: blobStorageAccountPrivateEndpointName
        properties: {
          privateLinkServiceId: blobStorageAccountId
          groupIds: [
            blobStorageAccountPrivateEndpointGroupName
          ]
        }
      }
    ]
    subnet: {
      id: subnetId
    }
    customDnsConfigs: [
      {
        fqdn: concat(blobStorageAccountName, blobPublicDNSZoneForwarder)
      }
    ]
  }
  dependsOn: [
    vnetId
    blobStorageAccountId
  ]
}

resource keyVaultPrivateDnsZoneGroupName 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-03-01' = {
  name: keyVaultPrivateDnsZoneGroupName_var
  location: location
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'dnsConfig'
        properties: {
          privateDnsZoneId: keyVaultPrivateDnsZoneId
        }
      }
    ]
  }
  dependsOn: [
    keyVaultId
    keyVaultPrivateDnsZoneId
    keyVaultPrivateEndpointId
  ]
}

resource blobPrivateDnsZoneGroupName 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-03-01' = {
  name: blobPrivateDnsZoneGroupName_var
  location: location
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'dnsConfig'
        properties: {
          privateDnsZoneId: blobPrivateDnsZoneId
        }
      }
    ]
  }
  dependsOn: [
    blobPrivateDnsZoneId
    blobStorageAccountPrivateEndpointId
  ]
}

output keyVaultPrivateEndpoint object = reference(keyVaultPrivateEndpointName_resource.id, '2020-04-01', 'Full')
output blobStorageAccountPrivateEndpoint object = reference(blobStorageAccountPrivateEndpointName_resource.id, '2020-04-01', 'Full')
output keyVault object = reference(keyVaultName_resource.id, '2019-09-01', 'Full')
output blobStorageAccount object = reference(blobStorageAccountName_resource.id, '2019-06-01', 'Full')
output scriptFileUri string = scriptFileUri
output environment object = environment()
