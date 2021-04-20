param entlzprefix string
param securityvnetname string
param securityvnetprefix string
param securitysubnetprefix string
param securityconnectivityrgname string
param location string
param hubtospokepeername string
param hubvnetname string
param hubvnetrgname string
param hubvnetsub string
param spoketohubpeername string

targetScope='subscription'

resource connectivityrg 'Microsoft.Resources/resourceGroups@2020-10-01'={
  location: location
  name: securityconnectivityrgname
}

module managemetnvnet 'spoke.bicep' = {
  scope: connectivityrg
  dependsOn:[
    connectivityrg
  ]
  name: '${entlzprefix}-security-vnet-${location}'
  params:{
    spokevnetname: securityvnetname
    spokevnetprefix: securityvnetprefix    
    managementsubnetprefix: securitysubnetprefix
    hubtospokepeername: hubtospokepeername
    hubvnetname: hubvnetname
    hubvnetrgname: hubvnetrgname
    hubvnetsub: hubvnetsub
    spoketohubpeername: spoketohubpeername
  }
}
