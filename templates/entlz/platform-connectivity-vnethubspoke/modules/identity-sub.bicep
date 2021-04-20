param entlzprefix string
param identityvnetname string
param identityvnetprefix string
param identitysubnetprefix string
param identityconnectivityrgname string
param location string
param hubtospokepeername string
param hubvnetname string
param hubvnetrgname string
param hubvnetsub string
param spoketohubpeername string

targetScope='subscription'

resource connectivityrg 'Microsoft.Resources/resourceGroups@2020-10-01'={
  location: location
  name: identityconnectivityrgname
}

module managemetnvnet 'spoke.bicep' = {
  scope: connectivityrg
  dependsOn:[
    connectivityrg
  ]
  name: identityvnetname
  params:{
    spokevnetname: identityvnetname
    spokevnetprefix: identityvnetprefix    
    managementsubnetprefix: identitysubnetprefix
    hubtospokepeername: hubtospokepeername
    hubvnetname: hubvnetname
    hubvnetrgname: hubvnetrgname
    hubvnetsub: hubvnetsub
    spoketohubpeername: spoketohubpeername
  }
}
