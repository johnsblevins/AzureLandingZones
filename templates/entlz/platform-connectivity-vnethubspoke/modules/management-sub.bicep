param entlzprefix string
param managementvnetname string
param managementvnetprefix string
param managementsubnetprefix string
param managementconnectivityrgname string

targetScope='subscription'

var location = deployment().location

resource connectivityrg 'Microsoft.Resources/resourceGroups@2020-10-01'={
  location: location
  name: managementconnectivityrgname
}

module managemetnvnet 'spoke.bicep' = {
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
