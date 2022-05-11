targetScope='resourceGroup'

resource sa 'Microsoft.Storage/storageAccounts@2021-06-01' ={
  name: 'goodsainfraencrypt123'
  location: resourceGroup().location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    encryption: {
      keySource: 'Microsoft.Storage'
      requireInfrastructureEncryption: true            
      services: {
        blob: {
          enabled: true
        }
        file: {
          enabled:true          
        }
        queue:{
          enabled: true
        }
        table:{
          enabled:true
        }
      }
    }
  }
}
