param routes array
param rtname string
param location string = resourceGroup().location

targetScope='resourceGroup'

resource rt 'Microsoft.Network/routeTables@2021-02-01' = {
  name: rtname
  location: location
  properties: {
    routes: routes
  }  
}

output id string = rt.id
