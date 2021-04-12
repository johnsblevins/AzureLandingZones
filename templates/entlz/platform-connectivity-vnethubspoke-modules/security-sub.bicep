param entlzprefix string
param securityvnetname string
param securityvnetprefix string
param securitysubnetprefix string

targetScope='subscription'

var location = deployment().location

resource connectivityrg 'Microsoft.Resources/resourceGroups@2020-10-01'={
  location: location
  name: '${entlzprefix}-security-connectivity-${location}'
}

module managemetnvnet 'modules/spokevnet.bicep' = {
  scope: connectivityrg
  dependsOn:[
    connectivityrg
  ]
  name: '${entlzprefix}-security-vnet-${location}'
  params:{
    spokevnetname: securityvnetname
    spokevnetprefix: securityvnetprefix    
    managementsubnetprefix: securitysubnetprefix
  }
}
