param saname string

var location = resourceGroup().location

resource sa 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  location: location
  name: saname
  kind: 'Storage'
  sku: {
    name: 'Premium_LRS'
    tier: 'Premium'
  }
  properties: {
    supportsHttpsTrafficOnly: true
  }
}
