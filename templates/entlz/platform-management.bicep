param entlzprefix string

var location = deployment().location

targetScope = 'subscription'

resource managementrg 'Microsoft.Resources/resourceGroups@2020-10-01' = {
  name: '${entlzprefix}-management'
  location: location
}

module loga 'modules/loga.bicep'={
  name: 'loga'
  dependsOn:[
    managementrg
  ]
  scope: managementrg
  params:{
    aaname: '${entlzprefix}-aa-${location}'
    loganame: '${entlzprefix}-loga-${location}'
  }
}
