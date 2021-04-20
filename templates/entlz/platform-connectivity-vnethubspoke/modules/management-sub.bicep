param entlzprefix string
param managementvnetname string
param managementvnetprefix string
param managementsubnetprefix string
param managementconnectivityrgname string
param location string
param hubtospokepeername string
param hubvnetname string
param hubvnetrgname string
param hubvnetsub string
param spoketohubpeername string

targetScope='subscription'

resource managementconnectivityrg 'Microsoft.Resources/resourceGroups@2020-10-01'={
  location: location
  name: managementconnectivityrgname
}

module managementvnet 'spoke.bicep' = {
  scope: managementconnectivityrg
  dependsOn:[
    managementconnectivityrg
  ]
  name: managementvnetname
  params:{
    spokevnetname: managementvnetname
    spokevnetprefix: managementvnetprefix    
    managementsubnetprefix: managementsubnetprefix
    hubtospokepeername: hubtospokepeername
    hubvnetname: hubvnetname
    hubvnetrgname: hubvnetrgname
    hubvnetsub: hubvnetsub
    spoketohubpeername: spoketohubpeername
  }
}
