param saname string

var location = resourceGroup().location

resource sa 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  location: location
  name: saname
  kind: 'StorageV2'
  sku: {
    name: 'Premium_ZRS'
    tier: 'Premium'
  }
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: false
    supportsHttpsTrafficOnly: true
  }
}
