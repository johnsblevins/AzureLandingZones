param kvName string = 'deskv'
param kvKeyName string = 'deskey'
param tenantId string = '6775f0cc-3aaf-4563-8857-e54a12ebb874'
param diskESName string = 'des'

resource kv 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: '${kvName}'
  location: resourceGroup().location
  properties:{    
    createMode: 'default'
    tenantId: '${tenantId}'
    sku: {
      name: 'premium'
      family: 'A'
    }
    networkAcls:{
      defaultAction: 'Deny'
      ipRules: []
    }        
    enablePurgeProtection:true
    accessPolicies:[]
  }
}

resource kvKey 'Microsoft.KeyVault/vaults/keys@2019-09-01' = {
  name: '${kvKeyName}'
  dependsOn:[
    kv
  ]
  parent: kv
  properties:{
    keySize: 4096
    kty: 'RSA-HSM'
  }
}

resource diskES 'Microsoft.Compute/diskEncryptionSets@2020-09-30' = {
  name: '${diskESName}'
  dependsOn:[
    kvKey
  ]
  location: resourceGroup().location
  identity:{
    type: 'SystemAssigned'
  }
  properties:{    
    activeKey: {
      keyUrl: kvKey.properties.keyUriWithVersion
      sourceVault: {
        id: kv.id
      }
    }
    encryptionType: 'EncryptionAtRestWithCustomerKey'
  }
}

resource kvAccess 'Microsoft.KeyVault/vaults/accessPolicies@2019-09-01' = {
  name: 'add'
  dependsOn:[
    diskES
  ]
  parent: kv
  properties:{    
    accessPolicies:[
      {
        objectId: diskES.identity.principalId        
        tenantId: tenantId
        permissions:{
          keys:[
            'list'
            'get'
            'wrapKey'
            'unwrapKey'
          ]
        }
      }
    ]
  }
}

output desName string = diskES.name


