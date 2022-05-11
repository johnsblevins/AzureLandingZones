targetScope='resourceGroup'

resource sa 'Microsoft.Storage/storageAccounts@2021-06-01' ={
  name: 'badsasecuretransfer123'
  location: resourceGroup().location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    supportsHttpsTrafficOnly: false
  }
}
