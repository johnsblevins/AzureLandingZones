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
param fwip string
param spokevnetrtname string
param spokevnetnsgname string

targetScope='subscription'

resource identityconnectivityrg 'Microsoft.Resources/resourceGroups@2020-10-01'={
  location: location
  name: identityconnectivityrgname
}

module identityvnet 'spoke.bicep' = {
  scope: identityconnectivityrg
  dependsOn:[
    identityconnectivityrg
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
    fwip: fwip
    spokevnetrtname: spokevnetrtname
    spokevnetnsgname: spokevnetnsgname
  }
}
