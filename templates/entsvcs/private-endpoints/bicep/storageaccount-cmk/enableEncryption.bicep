param msiObjectId string
param vaultUri string
param vaultName string
param accountName string
param location string
param keyName string

resource keyVaultAddPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2019-09-01' = {
  name: '${vaultName}/add'
  properties: {
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: msiObjectId
        permissions: {
          keys: [
            'wrapKey'
            'unwrapKey'
            'get'
          ]
          secrets: []
          certificates: []
        }
      }
    ]
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: accountName
  location: location
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
  kind: 'Storage'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    encryption: {
      services: {
        file: {
          enabled: true
        }
        blob: {
          enabled: true
        }
      }
      keySource: 'Microsoft.Keyvault'
      keyvaultproperties: {
        keyvaulturi: vaultUri
        keyname: keyName
      }
    }
  }
  dependsOn: [
    keyVaultAddPolicy
  ]
}
