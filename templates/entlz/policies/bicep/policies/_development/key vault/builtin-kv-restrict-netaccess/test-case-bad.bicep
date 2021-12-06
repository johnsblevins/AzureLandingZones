targetScope='resourceGroup'

resource kv 'Microsoft.KeyVault/vaults@2021-06-01-preview' ={
  name: 'badnetaccesskv123'
  location: resourceGroup().location  
  properties: {
    sku: {
      name: 'standard'
      family: 'A'
    }
    tenantId: subscription().tenantId
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        permissions: {                    
        }
        objectId: '36805b3f-52fb-4452-ba0b-085de56bf023'
      }
    ]
    networkAcls: {
      defaultAction: 'Allow'
    }    
  }
}
