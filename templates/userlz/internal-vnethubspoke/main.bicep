param appsubnetprefix string //App Subnet Prefix
param datasubnetprefix string //Data Subnet Prefix
param devenvironment string //(pr)od, (n)on(p)rod - 2 character MAX - pr or np
param fwip string //
param hosting string //(ext)ernal, (int)ernal, (s)and(b)o(x) - 3 character MAX - ext, int or sbx
param hubvnetsubid string //
param hubvnetrgname string  //
param hubvnetname string //
param managementsubnetprefix string //Management Subnet Prefix
param program string // Program Name - 5 character MAX
param subname string
param vnetprefix string //prod, nonprod, sandbox
param websubnetprefix string //Web Subnet Prefix

var tenantid = subscription().tenantId
var location = deployment().location
var connectivityrgname = '${subname}-connectivity-${location}'
var diskencryptionrgname = '${subname}-diskencryption-${location}'
var spokevnetname = '${subname}-vnet-${location}'
var hubtospokepeername = '${hubvnetname}-to-${spokevnetname}'
var spoketohubpeername = '${spokevnetname}-to-${hubvnetname}'
var spokevnetrtname = '${subname}-routetable-${location}'
var spokevnetnsgname = '${subname}-nsg-${location}'
var diskencryptionsetname = '${subname}-diskencryptionset-${location}'
var keyvaultname = '${subname}-keyvault-${location}'
var keyvaultkeyname = '${subname}-deskey-${location}'

targetScope = 'subscription'

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
    spokevnetrtname: spokevnetrtname
    appsubnetprefix: appsubnetprefix
    datasubnetprefix: datasubnetprefix
    hubvnetsubid: hubvnetsubid
    spokensgname: spokevnetnsgname
    websubnetprefix: websubnetprefix
  }
}

module diskencryption 'modules/diskEncryption.bicep' ={
  name: diskencryptionsetname
  dependsOn:[
    diskencryptionrg
  ]
  scope: diskencryptionrg
  params:{
    kvname: keyvaultname
    kvkeyname: keyvaultkeyname
    tenantid: tenantid
    diskesname: diskencryptionsetname
  }
}
