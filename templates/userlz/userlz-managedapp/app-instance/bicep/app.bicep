
targetScope='resourceGroup'

param saname string
param sku string = 'Standard_LRS'
param kind string = 'StorageV2'

resource app '' = {
  name: saname
  location: resourceGroup().location  
  sku: {
    name: sku    
  }
  kind: kind
  properties: {    
    supportsHttpsTrafficOnly: true
  }
}
