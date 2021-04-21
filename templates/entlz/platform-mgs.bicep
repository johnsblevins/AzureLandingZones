param entlzprefix string // Enterprise Landing Zone Prefix - 5 Characters Maximum

targetScope = 'tenant'

/////////// Create Management Group Hierarchy

// Root MG
module entLZRootMG 'modules/rootedmg.bicep'={
  name: 'entLZRootMG'
  params:{
    name: entlzprefix
  }
}

// Platform MGs
module platformMG 'modules/parentedmg.bicep'={
  name: 'platformMG'
  dependsOn: [
    entLZRootMG
  ]
  params:{
    name: '${entlzprefix}-platform'
    parentId: entLZRootMG.outputs.mgId
  }
}

module platformConnectivityMG 'modules/parentedmg.bicep'={
  name: 'platformConnectivityMG'
  dependsOn: [
    platformMG
  ]
  params:{
    name: '${entlzprefix}-connectivity'
    parentId: platformMG.outputs.mgId
  }
}

module platformIdentityMG 'modules/parentedmg.bicep'={
  name: 'platformIdentityMG'
  dependsOn: [
    platformMG
  ]
  params:{
    name: '${entlzprefix}-identity'
    parentId: platformMG.outputs.mgId
  }
}

module platformManagementMG 'modules/parentedmg.bicep'={
  name: 'platformManagementMG'
  dependsOn: [
    platformMG
  ]
  params:{
    name: '${entlzprefix}-management'
    parentId: platformMG.outputs.mgId
  }
}

module platformSecurityMG 'modules/parentedmg.bicep'={
  name: 'platformSecurityMG'
  dependsOn: [
    platformMG
  ]
  params:{
    name: '${entlzprefix}-security'
    parentId: platformMG.outputs.mgId
  }
}

// Landing Zone MGs
module landingZonesMG 'modules/parentedmg.bicep'={
  name: 'landingZonesMG'
  dependsOn: [
    entLZRootMG
  ]
  params:{
    name: '${entlzprefix}-landingzones'
    parentId: entLZRootMG.outputs.mgId
  }
}

module internal 'modules/parentedmg.bicep'={
  name: 'internal'
  dependsOn: [
    landingZonesMG
  ]
  params:{
    name: '${entlzprefix}-internal'
    parentId: landingZonesMG.outputs.mgId
  }
}

module internalProd 'modules/parentedmg.bicep'={
  name: 'internalProd'
  dependsOn: [
    internal
  ]
  params:{
    name: '${entlzprefix}-int-pr'
    parentId: internal.outputs.mgId
  }
}

module internalNonProd 'modules/parentedmg.bicep'={
  name: 'internalNonProd'
  dependsOn: [
    internal
  ]
  params:{
    name: '${entlzprefix}-int-np'
    parentId: internal.outputs.mgId
  }
}

module external 'modules/parentedmg.bicep'={
  name: 'external'
  dependsOn: [
    landingZonesMG
  ]
  params:{
    name: '${entlzprefix}-external'
    parentId: landingZonesMG.outputs.mgId
  }
}

module externalProd 'modules/parentedmg.bicep'={
  name: 'externalProd'
  dependsOn: [
    external
  ]
  params:{
    name: '${entlzprefix}-ext-pr'
    parentId: external.outputs.mgId
  }
}

module externalNonProd 'modules/parentedmg.bicep'={
  name: 'externalNonProd'
  dependsOn: [
    external
  ]
  params:{
    name: '${entlzprefix}-ext-np'
    parentId: external.outputs.mgId
  }
}

// Onboarding MG
module onboardingMG 'modules/parentedmg.bicep'={
  name: 'onboardingMG'
  dependsOn: [
    entLZRootMG
  ]
  params:{
    name: '${entlzprefix}-onboarding'
    parentId: entLZRootMG.outputs.mgId
  }
}

// Decommisioned MG
module decommissionedMG 'modules/parentedmg.bicep'={
  name: 'decommissionedMG'
  dependsOn: [
    entLZRootMG
  ]
  params:{
    name: '${entlzprefix}-decommissioned'
    parentId: entLZRootMG.outputs.mgId
  }
}

// Sandbox MGs
module sandboxMG 'modules/parentedmg.bicep'={
  name: 'sandboxMG'
  dependsOn: [
    entLZRootMG
  ]
  params:{
    name: '${entlzprefix}-sandboxes'
    parentId: entLZRootMG.outputs.mgId
  }
}

module sandboxManagementMG 'modules/parentedmg.bicep'={
  name: 'sandboxManagementMG'
  dependsOn: [
    sandboxMG
  ]
  params:{
    name: '${entlzprefix}-sandbox-management'
    parentId: sandboxMG.outputs.mgId
  }
}

module sandboxLandingZonesMG 'modules/parentedmg.bicep'={
  name: 'sandboxLandingZonesMG'
  dependsOn: [
    sandboxMG
  ]
  params:{
    name: '${entlzprefix}-sandbox-landingzones'
    parentId: sandboxMG.outputs.mgId
  }
}
