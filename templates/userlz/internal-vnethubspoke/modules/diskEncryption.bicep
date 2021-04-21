param kvname string
param kvkeyname string
param tenantid string
param diskesname string

resource kv 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: '${kvname}'
  location: resourceGroup().location
  properties:{    
    createMode: 'default'
    tenantId: '${tenantid}'
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
  name: '${kvkeyname}'
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
  name: '${diskesname}'
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
        tenantId: tenantid
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

resource diskencryptionsetlock 'Microsoft.Authorization/locks@2016-09-01'={
  name: 'diskencryptionsetlock'
  dependsOn:[
    diskES
    kvAccess
  ]
  properties: {
    level: 'ReadOnly'    
  }
  scope: diskES
}

resource keyvaultlock 'Microsoft.Authorization/locks@2016-09-01'={
  name: 'keyvaultlock'
  dependsOn:[
    diskES
    kvAccess
  ]
  properties: {
    level: 'ReadOnly'    
  }
  scope: kv
}

output kvid string = kv.id


