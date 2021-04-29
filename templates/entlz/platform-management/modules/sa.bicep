param saname string

var location = resourceGroup().location

resource sa 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  location: location
  name: saname
  kind: 'StorageV2'
  sku: {
    name: 'Standard_ZRS'
    tier: 'Premium'
  }

  properties: {

    supportsHttpsTrafficOnly: true

  }
}
