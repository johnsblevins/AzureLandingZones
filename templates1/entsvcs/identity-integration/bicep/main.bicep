var tenantId = subscription().tenantId

targetScope = 'subscription'

resource diskEncryptionRG 'Microsoft.Resources/resourceGroups@2020-10-01' = {
  name: 'identity-diskEncryption-${deployment().location}'
  location: deployment().location
}

resource addsRG 'Microsoft.Resources/resourceGroups@2020-10-01' = {
  name: 'identity-adds-${deployment().location}'
  location: deployment().location
}

resource adfsRG 'Microsoft.Resources/resourceGroups@2020-10-01' = {
  name: 'identity-adfs-${deployment().location}'
  location: deployment().location
}

resource aadcRG 'Microsoft.Resources/resourceGroups@2020-10-01' = {
  name: 'identity-aadc-${deployment().location}'
  location: deployment().location
}

module diskEncryption 'modules/diskEncryption.bicep' ={
  name: 'diskEncryption'
  dependsOn:[
    diskEncryptionRG
  ]
  scope: diskEncryptionRG
  params:{
    kvName:'identity-KV-${substring(deployment().location,0,8)}'
    kvKeyName: 'identity-DESKey-${deployment().location}'
    tenantId: '${tenantId}'
    diskESName:'identity-DES-${deployment().location}'
  }
}

module addsvm1 'modules/vm.bicep'={
  name: 'addsvm1'
  dependsOn:[
    diskEncryption
    addsRG
  ]
  scope: addsRG
  params:{
    vmName: 'addsvm1'
    adminUsername: 'azuradmin'
    adminPassword: 'password123!!'
    desName: diskEncryption.outputs.desName
    desRG: diskEncryptionRG.name
    privateIP: '10.254.4.4'
    subnetName: 'identity'
    vnetName: 'TSDLZ-identity-USGovVirginia'
    vmSize: 'Standard_B2s'
    vnetRG: 'TSDLZ-identity-connectivity'
    zone: '1'
  }
}

module addsvm2 'modules/vm.bicep'={
  name: 'addsvm2'
  dependsOn:[
    diskEncryption
    addsRG
  ]
  scope: addsRG
  params:{
    vmName: 'adds1'
    adminUsername: 'azuradmin'
    adminPassword: 'password123!!'
    desName: diskEncryption.outputs.desName
    desRG: diskEncryptionRG.name
    privateIP: '10.254.4.5'
    subnetName: 'identity'
    vnetName: 'TSDLZ-identity-USGovVirginia'
    vmSize: 'Standard_B2s'
    vnetRG: 'TSDLZ-identity-connectivity'
    zone: '2'
  }
}


module adfsvm1 'modules/vm.bicep'={
  name: 'adfsvm1'
  dependsOn:[
    diskEncryption
    adfsRG
  ]
  scope: adfsRG
  params:{
    vmName: 'adfsvm1'
    adminUsername: 'azuradmin'
    adminPassword: 'password123!!'
    desName: diskEncryption.outputs.desName
    desRG: diskEncryptionRG.name
    subnetName: 'identity'
    privateIP: '10.254.4.6'
    vnetName: 'TSDLZ-identity-USGovVirginia'
    vmSize: 'Standard_B2s'
    vnetRG: 'TSDLZ-identity-connectivity'
    zone: '1'
  }
}

module adfsvm2 'modules/vm.bicep'={
  name: 'adfsvm2'
  dependsOn:[
    diskEncryption
    adfsRG
  ]
  scope: adfsRG
  params:{
    vmName: 'adfsvm2'
    adminUsername: 'azuradmin'
    adminPassword: 'password123!!'
    desName: diskEncryption.outputs.desName
    desRG: diskEncryptionRG.name
    subnetName: 'identity'
    privateIP: '10.254.4.7'
    vnetName: 'TSDLZ-identity-USGovVirginia'
    vmSize: 'Standard_B2s'
    vnetRG: 'TSDLZ-identity-connectivity'
    zone: '2'
  }
}

module aadcvm1 'modules/vm.bicep'={
  name: 'aadcvm1'
  dependsOn:[
    diskEncryption
    aadcRG
  ]
  scope: aadcRG
  params:{
    vmName: 'aadcvm1'
    adminUsername: 'azuradmin'
    adminPassword: 'password123!!'
    desName: diskEncryption.outputs.desName
    desRG: diskEncryptionRG.name
    subnetName: 'identity'
    privateIP: '10.254.4.8'
    vnetName: 'TSDLZ-identity-USGovVirginia'
    vmSize: 'Standard_B2s'
    vnetRG: 'TSDLZ-identity-connectivity'
    zone: '1'
  }
}

module aadcvm2 'modules/vm.bicep'={
  name: 'aadcvm2'
  dependsOn:[
    diskEncryption
    aadcRG
  ]
  scope: aadcRG
  params:{
    vmName: 'aadcvm2'
    adminUsername: 'azuradmin'
    adminPassword: 'password123!!'
    desName: diskEncryption.outputs.desName
    desRG: diskEncryptionRG.name
    subnetName: 'identity'
    privateIP: '10.254.4.9'
    vnetName: 'TSDLZ-identity-USGovVirginia'
    vmSize: 'Standard_B2s'
    vnetRG: 'TSDLZ-identity-connectivity'
    zone: '2'
  }
}
