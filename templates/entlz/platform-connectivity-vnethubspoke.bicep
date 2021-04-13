param entlzprefix string
param environment string
param location string
param connectivitysubid string
param identitysubid string
param securitysubid string
param managementsubid string
param hubvnetprefix string
param gwtype string = ''
param gwsubnetprefix string = ''
param fwtype string = ''
param fwsubnetprefix string = ''
param fwmanagementsubnetprefix string = ''
param bastionsubnetprefix string = ''
param managementvnetprefix string
param managementsubnetprefix string
param identityvnetprefix string
param identitysubnetprefix string
param securityvnetprefix string
param securitysubnetprefix string

targetScope='managementGroup'

module connectivitysub 'platform-connectivity-vnethubspoke-modules/connectivity-sub.bicep' ={
  name: 'connectivitysub'
  scope: subscription(connectivitysubid)
  params:{
    bastionname: '${entlzprefix}-hub-bastion-${location}'
    bastionsubnetprefix: bastionsubnetprefix
    entlzprefix: entlzprefix
    fwname: '${entlzprefix}-hub-fw-${location}'
    fwsubnetprefix: fwsubnetprefix
    fwtype: fwtype
    gwname: '${entlzprefix}-hub-gw-${location}'
    gwsubnetprefix: gwsubnetprefix
    gwtype: gwtype
    hubvnetname: '${entlzprefix}-hub-vnet-${location}'
    hubvnetprefix: hubvnetprefix
    environment: environment
    fwmanagementsubnetprefix: fwmanagementsubnetprefix
  }
}

module managementsub 'platform-connectivity-vnethubspoke-modules/management-sub.bicep' ={
  name: 'managementsub'
  scope: subscription(managementsubid)
  params:{
    entlzprefix: entlzprefix
    managementsubnetprefix: managementsubnetprefix
    managementvnetname: '${entlzprefix}-management-vnet-${location}'
    managementvnetprefix: managementvnetprefix
  }
}

module identitysub 'platform-connectivity-vnethubspoke-modules/identity-sub.bicep' ={
  name: 'identitysub'
  scope: subscription(identitysubid)
  params:{
    entlzprefix: entlzprefix
    identitysubnetprefix: identitysubnetprefix
    identityvnetname: '${entlzprefix}-identity-vnet-${location}'
    identityvnetprefix: identityvnetprefix
  }
}

module securitysub 'platform-connectivity-vnethubspoke-modules/security-sub.bicep' ={
  name: 'securitysub'
  scope: subscription(securitysubid)
  params:{
    entlzprefix: entlzprefix
    securitysubnetprefix: securitysubnetprefix
    securityvnetname: '${entlzprefix}-security-vnet-${location}'
    securityvnetprefix: securityvnetprefix
  }
}

