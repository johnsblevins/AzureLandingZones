param entlzprefix string = 'elz1' 
param location string = 'usgovvirginia'
param environment string = 'usgovernment'
param subscriptionId string = 'f86eed1f-a251-4b29-a8b3-98089b46ce6c'
param vnetprefixtype string = '10.0.0.0/23'
param fwsubnetprefixtype  string = '10.0.0.0/26'
param fwmanagementsubnetprefixtype string = '10.0.0.64/26'
param bastionsubnetprefixtype string = '10.0.0.128/27'
param managementsubnetprefixtype string = '10.0.1.0/26'
param fwskutype string = 'Standard'

targetScope = 'subscription'

var subname = subscription().displayName
var tenantid = subscription().tenantId
var connectivityrgname = '${subname}-connectivity-${location}'
var diskencryptionrgname = '${subname}-diskencryption-${location}'
var spokevnetname = '${subname}-vnet-${location}'
var hubtospokepeername = '${hubvnetname}-to-${spokevnetname}'
var spoketohubpeername = '${spokevnetname}-to-${hubvnetname}'

resource connectivityrg 'Microsoft.Resources/resourceGroups@2020-10-01' = {
  name: connectivityrgname
  location: location
}

resource diskencryptionrg 'Microsoft.Resources/resourceGroups@2020-10-01' = {
  name: diskencryptionrgname
  location: location
}

module spokevnet 'modules/spoke.bicep'={
  name: spokevnetname
  scope: connectivityrg
  params:{
    fwip: fwip
    hubtospokepeername: hubtospokepeername
    hubvnetname: hubvnetname
    hubvnetrgname: hubvnetrgname
    managementsubnetprefix: managementsubnetprefix
    spoketohubpeername: spoketohubpeername
    spokevnetname: spokevnetname
    spokevnetprefix: vnetprefix
    subrtname: subrtname
    appsubnetprefix: appsubnetprefix
    datasubnetprefix: datasubnetprefix
    hubvnetsubid: hubvnetsubid
    subnsgname: subnsgname
    websubnetprefix: websubnetprefix
  }
}

module diskencryption 'modules/diskEncryption.bicep' ={
  name: subdesname
  dependsOn:[
    diskencryptionrg
  ]
  scope: diskencryptionrg
  params:{
    subkvname: subkvname
    subkvkeyname: subkvkeyname
    tenantid: tenantid
    subdesname: subdesname
  }
}


