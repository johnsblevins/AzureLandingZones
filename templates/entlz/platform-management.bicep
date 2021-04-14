param entlzprefix string
param uniqueid string = ''


var location = deployment().location

targetScope = 'subscription'

resource managementrg 'Microsoft.Resources/resourceGroups@2020-10-01' = {
  name: '${entlzprefix}-management-${location}'
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
    loganame: '${entlzprefix}-loga-${location}${uniqueid}'
  }
}

module sa 'modules/sa.bicep' = {
  name: 'sa'
  dependsOn:[
    managementrg
  ]
  scope: managementrg
  params:{
    saname: '${entlzprefix}sa${location}${uniqueid}'
  }
}
