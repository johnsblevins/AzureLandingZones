param entlzprefix string
param identityvnetname string
param identityvnetprefix string
param identitysubnetprefix string

targetScope='subscription'

var location = deployment().location

resource connectivityrg 'Microsoft.Resources/resourceGroups@2021-01-01'={
  location: location
  name: '${entlzprefix}-identity-connectivity-${location}'
}

module managemetnvnet 'modules/spokevnet.bicep' = {
  scope: connectivityrg
  dependsOn:[
    connectivityrg
  ]
  name: '${entlzprefix}-identity-vnet-${location}'
  params:{
    spokevnetname: identityvnetname
    spokevnetprefix: identityvnetprefix    
    managementsubnetprefix: identitysubnetprefix
  }
}
