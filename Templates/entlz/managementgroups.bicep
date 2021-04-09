param entLZPrefix string // Enterprise Landing Zone Prefix - 5 Characters Maximum

targetScope = 'tenant'

/////////// Create Management Group Hierarchy

// Root MG
module entLZRootMG 'modules/rootedMG.bicep'={
  name: 'entLZRootMG'
  params:{
    name: entLZPrefix
  }
}

// Platform MGs
module platformMG 'modules/parentedMG.bicep'={
  name: 'platformMG'
  dependsOn: [
    entLZRootMG
  ]
  params:{
    name: '${entLZPrefix}-platform'
    parentId: entLZRootMG.outputs.mgId
  }
}

module platformConnectivityMG 'modules/parentedMG.bicep'={
  name: 'platformConnectivityMG'
  dependsOn: [
    platformMG
  ]
  params:{
    name: '${entLZPrefix}-connectivity'
    parentId: platformMG.outputs.mgId
  }
}

module platformIdentityMG 'modules/parentedMG.bicep'={
  name: 'platformIdentityMG'
  dependsOn: [
    platformMG
  ]
  params:{
    name: '${entLZPrefix}-identity'
    parentId: platformMG.outputs.mgId
  }
}

module platformManagementMG 'modules/parentedMG.bicep'={
  name: 'platformManagementMG'
  dependsOn: [
    platformMG
  ]
  params:{
    name: '${entLZPrefix}-management'
    parentId: platformMG.outputs.mgId
  }
}

module platformSecurityMG 'modules/parentedMG.bicep'={
  name: 'platformSecurityMG'
  dependsOn: [
    platformMG
  ]
  params:{
    name: '${entLZPrefix}-security'
    parentId: platformMG.outputs.mgId
  }
}

// Landing Zone MGs
module landingZonesMG 'modules/parentedMG.bicep'={
  name: 'landingZonesMG'
  dependsOn: [
    entLZRootMG
  ]
  params:{
    name: '${entLZPrefix}-landingzones'
    parentId: entLZRootMG.outputs.mgId
  }
}

module internal 'modules/parentedMG.bicep'={
  name: 'internal'
  dependsOn: [
    landingZonesMG
  ]
  params:{
    name: '${entLZPrefix}-internal'
    parentId: landingZonesMG.outputs.mgId
  }
}

module internalProd 'modules/parentedMG.bicep'={
  name: 'internalProd'
  dependsOn: [
    internal
  ]
  params:{
    name: '${entLZPrefix}-internal-prod'
    parentId: internal.outputs.mgId
  }
}

module internalNonProd 'modules/parentedMG.bicep'={
  name: 'internalNonProd'
  dependsOn: [
    internal
  ]
  params:{
    name: '${entLZPrefix}-internal-nonprod'
    parentId: internal.outputs.mgId
  }
}

module external 'modules/parentedMG.bicep'={
  name: 'external'
  dependsOn: [
    landingZonesMG
  ]
  params:{
    name: '${entLZPrefix}-external'
    parentId: landingZonesMG.outputs.mgId
  }
}

module externalProd 'modules/parentedMG.bicep'={
  name: 'externalProd'
  dependsOn: [
    external
  ]
  params:{
    name: '${entLZPrefix}-external-prod'
    parentId: external.outputs.mgId
  }
}

module externalNonProd 'modules/parentedMG.bicep'={
  name: 'externalNonProd'
  dependsOn: [
    external
  ]
  params:{
    name: '${entLZPrefix}-external-nonprod'
    parentId: external.outputs.mgId
  }
}

// Onboarding MG
module onboardingMG 'modules/parentedMG.bicep'={
  name: 'onboardingMG'
  dependsOn: [
    entLZRootMG
  ]
  params:{
    name: '${entLZPrefix}-onboarding'
    parentId: entLZRootMG.outputs.mgId
  }
}

// Decommisioned MG
module decommissionedMG 'modules/parentedMG.bicep'={
  name: 'decommissionedMG'
  dependsOn: [
    entLZRootMG
  ]
  params:{
    name: '${entLZPrefix}-decommissioned'
    parentId: entLZRootMG.outputs.mgId
  }
}

// Sandbox MGs
module sandboxMG 'modules/parentedMG.bicep'={
  name: 'sandboxMG'
  dependsOn: [
    entLZRootMG
  ]
  params:{
    name: '${entLZPrefix}-sandboxes'
    parentId: entLZRootMG.outputs.mgId
  }
}

module sandboxManagementMG 'modules/parentedMG.bicep'={
  name: 'sandboxManagementMG'
  dependsOn: [
    sandboxMG
  ]
  params:{
    name: '${entLZPrefix}-sandbox-management'
    parentId: sandboxMG.outputs.mgId
  }
}

module sandboxLandingZonesMG 'modules/parentedMG.bicep'={
  name: 'sandboxLandingZonesMG'
  dependsOn: [
    sandboxMG
  ]
  params:{
    name: '${entLZPrefix}-sandbox-landingzones'
    parentId: sandboxMG.outputs.mgId
  }
}
