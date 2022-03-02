@description('Specifies the location for all the resources.')
param location string = resourceGroup().location

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
  'standard'
  'premium'
])
param skuName string = 'standard'

@description('Specifies the name of the private link to key vault.')
param keyVaultPrivateEndpointName string = 'KeyVaultPrivateEndpoint'

@description('Specifies the id of the virtual network.')
param virtualNetworkId string

@description('Specifies the name of the default subnet hosting the AKS cluster.')
param subnetName string = 'kvSubnet'

@description('Specifies the Private DNS Zone Id.')
param keyVaultPrivateDnsZoneId string

var keyVaultPublicDNSZoneForwarder = ((toLower(environment().name) == 'azureusgovernment') ? '.vaultcore.usgovcloudapi.net' : '.vaultcore.azure.net')
var blobPublicDNSZoneForwarder = '.blob.${environment().suffixes.storage}'
var keyVaultPrivateDnsZoneName_var = 'privatelink${keyVaultPublicDNSZoneForwarder}'
var keyVaultPrivateEndpointId = keyVaultPrivateEndpointName_resource.id
var keyVaultPrivateEndpointGroupName = 'vault'
var keyVaultPrivateDnsZoneGroupName_var = '${keyVaultPrivateEndpointName}/${keyVaultPrivateEndpointGroupName}PrivateDnsZoneGroup'
var keyVaultPrivateDnsZoneGroupId = resourceId('Microsoft.Network/privateEndpoints/privateDnsZoneGroups', keyVaultPrivateEndpointName, '${keyVaultPrivateEndpointGroupName}PrivateDnsZoneGroup')

var virtualNetworkName = last(split(virtualNetworkId, '/'))
var virtualNetworkSubId = split(virtualNetworkId, '/')[2]
var virtualNetworkRGName = split(virtualNetworkId, '/')[4]


resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-08-01' existing = {
  name: virtualNetworkName
  scope: resourceGroup(virtualNetworkSubId, virtualNetworkRGName)
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2020-08-01' existing = {
  parent: virtualNetwork
  name: subnetName
}

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
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
    accessPolicies: []
  }  
}

resource keyVaultPrivateEndpoint 'Microsoft.Network/privateEndpoints@2020-04-01' = {
  name: keyVaultPrivateEndpointName
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: keyVaultPrivateEndpointName
        properties: {
          privateLinkServiceId: keyVault.id
          groupIds: [
            keyVaultPrivateEndpointGroupName
          ]
        }
      }
    ]
    subnet: {
      id: subnet.id
    }
    customDnsConfigs: [
      {
        fqdn: '${keyVaultName}${keyVaultPublicDNSZoneForwarder}'
      }
    ]
  }
  dependsOn: []
}

resource keyVaultPrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-03-01' = {
  name: keyVaultPrivateDnsZoneGroupName_var  
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
    keyVault
    keyVaultPrivateEndpoint
  ]
}


output keyVaultPrivateEndpoint object = reference(keyVaultPrivateEndpointName_resource.id, '2020-04-01', 'Full')
output keyVault object = reference(keyVaultName_resource.id, '2019-09-01', 'Full')
output env object = environment()
