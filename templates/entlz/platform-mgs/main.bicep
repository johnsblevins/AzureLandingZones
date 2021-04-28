param entlzprefix string // Enterprise Landing Zone Prefix - 5 Characters Maximum
param basetime string = utcNow()

targetScope = 'tenant'

/////////// Create Management Group Hierarchy
var deploymentguid  = '${guid(basetime)}'

// Root MG
module entLZRootMG 'modules/rootedmg.bicep'={
  name: '${entlzprefix}-root-mg-${deploymentguid}'
  params:{
    name: entlzprefix
  }
}

// Platform MGs
module platformMG 'modules/parentedmg.bicep'={
  name: '${entlzprefix}-platform-mg-${deploymentguid}'
  dependsOn: [
    entLZRootMG
  ]
  params:{
    name: '${entlzprefix}-platform'
    parentId: entLZRootMG.outputs.mgId
  }
}

module platformConnectivityMG 'modules/parentedmg.bicep'={
  name: '${entlzprefix}-platform-mg-${deploymentguid}'
  dependsOn: [
    platformMG
  ]
  params:{
    name: '${entlzprefix}-platform'
    parentId: platformMG.outputs.mgId
  }
}

module platformIdentityMG 'modules/parentedmg.bicep'={
  name: '${entlzprefix}-identity-mg-${deploymentguid}'
  dependsOn: [
    platformMG
  ]
  params:{
    name: '${entlzprefix}-identity'
    parentId: platformMG.outputs.mgId
  }
}

module platformManagementMG 'modules/parentedmg.bicep'={
  name: '${entlzprefix}-management-mg-${deploymentguid}'
  dependsOn: [
    platformMG
  ]
  params:{
    name: '${entlzprefix}-management'
    parentId: platformMG.outputs.mgId
  }
}

module platformSecurityMG 'modules/parentedmg.bicep'={
  name: '${entlzprefix}-security-mg-${deploymentguid}'
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
  name: '${entlzprefix}-landingzones-mg-${deploymentguid}'
  dependsOn: [
    entLZRootMG
  ]
  params:{
    name: '${entlzprefix}-landingzones'
    parentId: entLZRootMG.outputs.mgId
  }
}

module internal 'modules/parentedmg.bicep'={
  name: '${entlzprefix}-internal-mg-${deploymentguid}'
  dependsOn: [
    landingZonesMG
  ]
  params:{
    name: '${entlzprefix}-internal'
    parentId: landingZonesMG.outputs.mgId
  }
}

module internalProd 'modules/parentedmg.bicep'={
  name: '${entlzprefix}-int-pr-mg-${deploymentguid}'
  dependsOn: [
    internal
  ]
  params:{
    name: '${entlzprefix}-int-pr'
    parentId: internal.outputs.mgId
  }
}

module internalNonProd 'modules/parentedmg.bicep'={
  name: '${entlzprefix}-int-np-mg-${deploymentguid}'
  dependsOn: [
    internal
  ]
  params:{
    name: '${entlzprefix}-int-np'
    parentId: internal.outputs.mgId
  }
}

module external 'modules/parentedmg.bicep'={
  name: '${entlzprefix}-external-mg-${deploymentguid}'
  dependsOn: [
    landingZonesMG
  ]
  params:{
    name: '${entlzprefix}-external'
    parentId: landingZonesMG.outputs.mgId
  }
}

module externalProd 'modules/parentedmg.bicep'={
  name: '${entlzprefix}-ext-pr-mg-${deploymentguid}'
  dependsOn: [
    external
  ]
  params:{
    name: '${entlzprefix}-ext-pr'
    parentId: external.outputs.mgId
  }
}

module externalNonProd 'modules/parentedmg.bicep'={
  name: '${entlzprefix}-ext-np-mg-${deploymentguid}'
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
  name: '${entlzprefix}-onboarding-mg-${deploymentguid}'
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
  name: '${entlzprefix}-decommissioned-mg-${deploymentguid}'
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
  name: '${entlzprefix}-sandboxes-mg-${deploymentguid}'
  dependsOn: [
    entLZRootMG
  ]
  params:{
    name: '${entlzprefix}-sandboxes'
    parentId: entLZRootMG.outputs.mgId
  }
}

module sandboxManagementMG 'modules/parentedmg.bicep'={
  name: '${entlzprefix}-sandbox-management-mg-${deploymentguid}'
  dependsOn: [
    sandboxMG
  ]
  params:{
    name: '${entlzprefix}-sandbox-management'
    parentId: sandboxMG.outputs.mgId
  }
}

module sandboxLandingZonesMG 'modules/parentedmg.bicep'={
  name: '${entlzprefix}-sandbox-landingzones-mg-${deploymentguid}'
  dependsOn: [
    sandboxMG
  ]
  params:{
    name: '${entlzprefix}-sandbox-landingzones'
    parentId: sandboxMG.outputs.mgId
  }
}
