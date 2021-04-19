param entlzprefix string
param managementvnetname string
param managementvnetprefix string
param managementsubnetprefix string

targetScope='subscription'

var location = deployment().location

resource connectivityrg 'Microsoft.Resources/resourceGroups@2020-10-01'={
  location: location
  name: '${entlzprefix}-management-connectivity-${location}'
}

module managemetnvnet 'modules/spoke.bicep' = {
  scope: connectivityrg
  dependsOn:[
    connectivityrg
  ]
  name: '${entlzprefix}-management-vnet-${location}'
  params:{
    spokevnetname: managementvnetname
    spokevnetprefix: managementvnetprefix    
    managementsubnetprefix: managementsubnetprefix
  }
}
