param keyName string = 'cmk'
param keyVersion string = '1'
param vaultName string = 'jsbcmkkv01'
param location string = resourceGroup().location
param accountName string = 'jsbcmksa01'

resource storageAcc 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
  kind: 'Storage'
  name: accountName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    supportsHttpsTrafficOnly: true
  }
  dependsOn: []
}

resource keyVault 'Microsoft.KeyVault/vaults@2016-10-01' = {
  name: vaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    accessPolicies: []
    enabledForDeployment: true
    enabledForDiskEncryption: true
    enabledForTemplateDeployment: true
    enableSoftDelete: true    
    enablePurgeProtection: true
  }
}

resource key 'Microsoft.KeyVault/vaults/keys@2021-11-01-preview'={
  name: keyName
  parent: keyVault
  properties:{
    kty: 'RSA'
  }
}

module updateStorageAccount './enableEncryption.bicep' = {
  name: 'updateStorageAccount'
  dependsOn: [
    key
  ]
  params: {
    msiObjectId: storageAcc.identity.principalId
    vaultUri: keyVault.properties.vaultUri
    vaultName: vaultName
    accountName: accountName
    location: location
    keyName: keyName
  }
}
