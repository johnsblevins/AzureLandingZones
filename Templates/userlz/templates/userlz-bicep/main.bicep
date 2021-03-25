param programName string // Program Name - 5 character MAX
param programType string //(ext)ernal, (int)ernal, (s)and(b)o(x) - 3 character MAX - ext, int or sbx
param programEnv string //(pr)od, (n)on(p)rod - 2 character MAX - pr or np
param vnetPrefix string //prod, nonprod, sandbox
param mgmtSubnetPrefix string //Management Subnet Prefix
param webSubnetPrefix string //Web Subnet Prefix
param appSubnetPrefix string //App Subnet Prefix
param dataSubnetPrefix string //Data Subnet Prefix
param firewallIP string //
param HubVNETSub string //
param HubVNETRG string  //
param HubVNETName string //
param peerSpokeToHub string //
param peerHubToSpoke string //

var resourcePrefix = '${programName}-${programType}-${programEnv}'
var tenantId = subscription().tenantId

targetScope = 'subscription'

resource connectivityRG 'Microsoft.Resources/resourceGroups@2020-10-01' = {
  name: '${resourcePrefix}-connectivity'
  location: deployment().location
}

resource lockedRG 'Microsoft.Resources/resourceGroups@2020-10-01' = {
  name: '${resourcePrefix}-lockedRG'
  location: deployment().location
}

module lockedNSG 'modules/nsg.bicep'={
  name: 'lockedNSG'
  dependsOn:[
    lockedRG
  ]
  scope: lockedRG
  params:{
    nsgName: '${resourcePrefix}-lockedNSG'
  }
}

module lockedRouteTable 'modules/routeTable.bicep'={
  name: 'lockedRouteTable'
  dependsOn:[
    lockedRG
  ]
  scope: lockedRG
  params:{
    rtName: '${resourcePrefix}-lockedRT'
    firewallIP: firewallIP
  }
}

module lockedDiskEncryption 'modules/diskEncryption.bicep' ={
  name: 'lockedDiskES'
  dependsOn:[
    lockedRG
  ]
  scope: lockedRG
  params:{
    kvName:'${resourcePrefix}-lockedKV'
    kvKeyName: '${resourcePrefix}-DESKey'
    tenantId: '${tenantId}'
    diskESName:'${resourcePrefix}-lockedDES'
  }
}

module vnetDeploy 'modules/vnet.bicep' = {
  name: 'deployProgramVnet'
  dependsOn:[
    lockedNSG
    lockedRouteTable
    lockedDiskEncryption
  ]
  scope: connectivityRG
  params: {
    vnetName: '${resourcePrefix}-vnet'
    vnetPrefix: vnetPrefix
    mgmtSubnetPrefix: mgmtSubnetPrefix
    webSubnetPrefix: webSubnetPrefix
    appSubnetPrefix: appSubnetPrefix
    dataSubnetPrefix: dataSubnetPrefix
    nsgID: lockedNSG.outputs.nsgID
    rtID: lockedRouteTable.outputs.rtId
  }
}

module rgLock 'modules/lock.bicep'={
  name: 'rgLock'
  scope: lockedRG
  dependsOn:[
    lockedNSG
    lockedRouteTable
    lockedDiskEncryption    
  ]
}

module spokeToHubPeer 'modules/peering.bicep'={
  name: 'spokeToHubPeer'
  dependsOn:[
    vnetDeploy
  ]
  scope: connectivityRG
  params:{
    srcVNETName:'${resourcePrefix}-vnet'
    dstVNETName: HubVNETName
    dstVNETRG: HubVNETRG
    dstVNETSub: HubVNETSub
    peerName: '${resourcePrefix}-to-hub'  
  }
}

resource hubVNETRG 'Microsoft.Resources/resourceGroups@2020-10-01' existing={
  name: '${HubVNETRG}'
  scope: subscription('${HubVNETSub}')
}

module hubToSpokePeer 'modules/peering.bicep'={
  name: 'hubToSpokePeer'
  dependsOn:[
    vnetDeploy
  ]
  scope: hubVNETRG
  params:{
    srcVNETName:'${HubVNETName}'
    dstVNETName: '${resourcePrefix}-vnet'
    dstVNETRG: connectivityRG.name
    dstVNETSub: subscription().subscriptionId
    peerName: 'hub-to-${resourcePrefix}'  
  }
}
