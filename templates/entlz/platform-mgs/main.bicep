param entlzprefix string // Enterprise Landing Zone Prefix - 5 Characters Maximum
param randomid string = uniqueString(utcNow())

targetScope = 'tenant'

// Root MG
module entLZRootMG 'modules/rootedmg.bicep'={
  name: '${entlzprefix}-root-mg-${randomid}'
  params:{
    name: entlzprefix
  }
}

// Platform MGs
module platformMG 'modules/parentedmg.bicep'={
  name: '${entlzprefix}-platform-mg-${randomid}'
  dependsOn: [
    entLZRootMG
  ]
  params:{
    name: '${entlzprefix}-platform'
    parentId: entLZRootMG.outputs.mgId
  }
}

module platformConnectivityMG 'modules/parentedmg.bicep'={
  name: '${entlzprefix}-connectivity-mg-${randomid}'
  dependsOn: [
    platformMG
  ]
  params:{
    name: '${entlzprefix}-connectivity'
    parentId: platformMG.outputs.mgId
  }
}

module platformIdentityMG 'modules/parentedmg.bicep'={
  name: '${entlzprefix}-identity-mg-${randomid}'
  dependsOn: [
    platformMG
  ]
  params:{
    name: '${entlzprefix}-identity'
    parentId: platformMG.outputs.mgId
  }
}

module platformManagementMG 'modules/parentedmg.bicep'={
  name: '${entlzprefix}-management-mg-${randomid}'
  dependsOn: [
    platformMG
  ]
  params:{
    name: '${entlzprefix}-management'
    parentId: platformMG.outputs.mgId
  }
}

module platformSecurityMG 'modules/parentedmg.bicep'={
  name: '${entlzprefix}-security-mg-${randomid}'
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
  name: '${entlzprefix}-landingzones-mg-${randomid}'
  dependsOn: [
    entLZRootMG
  ]
  params:{
    name: '${entlzprefix}-landingzones'
    parentId: entLZRootMG.outputs.mgId
  }
}

module internal 'modules/parentedmg.bicep'={
  name: '${entlzprefix}-internal-mg-${randomid}'
  dependsOn: [
    landingZonesMG
  ]
  params:{
    name: '${entlzprefix}-internal'
    parentId: landingZonesMG.outputs.mgId
  }
}

module internalProd 'modules/parentedmg.bicep'={
  name: '${entlzprefix}-int-pr-mg-${randomid}'
  dependsOn: [
    internal
  ]
  params:{
    name: '${entlzprefix}-int-pr'
    parentId: internal.outputs.mgId
  }
}

module internalNonProd 'modules/parentedmg.bicep'={
  name: '${entlzprefix}-int-np-mg-${randomid}'
  dependsOn: [
    internal
  ]
  params:{
    name: '${entlzprefix}-int-np'
    parentId: internal.outputs.mgId
  }
}

module external 'modules/parentedmg.bicep'={
  name: '${entlzprefix}-external-mg-${randomid}'
  dependsOn: [
    landingZonesMG
  ]
  params:{
    name: '${entlzprefix}-external'
    parentId: landingZonesMG.outputs.mgId
  }
}

module externalProd 'modules/parentedmg.bicep'={
  name: '${entlzprefix}-ext-pr-mg-${randomid}'
  dependsOn: [
    external
  ]
  params:{
    name: '${entlzprefix}-ext-pr'
    parentId: external.outputs.mgId
  }
}

module externalNonProd 'modules/parentedmg.bicep'={
  name: '${entlzprefix}-ext-np-mg-${randomid}'
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
  name: '${entlzprefix}-onboarding-mg-${randomid}'
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
  name: '${entlzprefix}-decommissioned-mg-${randomid}'
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
  name: '${entlzprefix}-sandboxes-mg-${randomid}'
  dependsOn: [
    entLZRootMG
  ]
  params:{
    name: '${entlzprefix}-sandboxes'
    parentId: entLZRootMG.outputs.mgId
  }
}

module sandboxManagementMG 'modules/parentedmg.bicep'={
  name: '${entlzprefix}-sandbox-management-mg-${randomid}'
  dependsOn: [
    sandboxMG
  ]
  params:{
    name: '${entlzprefix}-sandbox-management'
    parentId: sandboxMG.outputs.mgId
  }
}

module sandboxLandingZonesMG 'modules/parentedmg.bicep'={
  name: '${entlzprefix}-sandbox-landingzones-mg-${randomid}'
  dependsOn: [
    sandboxMG
  ]
  params:{
    name: '${entlzprefix}-sandbox-landingzones'
    parentId: sandboxMG.outputs.mgId
  }
}
