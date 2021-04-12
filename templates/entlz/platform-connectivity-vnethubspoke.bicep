param entlzprefix string
param location string
param connectivitysubid string
param identitysubid string
param securitysubid string
param managementsubid string
param hubvnetname string
param hubvnetprefix string
param gwname string = ''
param gwtype string = ''
param gwsubnetprefix string = ''
param fwname string = ''
param fwtype string = ''
param fwsubnetprefix string = ''
param bastionname string = ''
param bastionsubnetprefix string = ''
param managementvnetname string
param managementvnetprefix string
param managementsubnetprefix string
param identityvnetname string
param identityvnetprefix string
param identitysubnetprefix string
param securityvnetname string
param securityvnetprefix string
param securitysubnetprefix string

targetScope='managementGroup'

module connectivitysub 'platform-connectivity-vnethubspoke-modules/connectivity-sub.bicep'={
  name: 'connectivitysub'
  scope: subscription(connectivitysubid)
  params:{
    bastionname: bastionname
    bastionsubnetprefix: bastionsubnetprefix
    entlzprefix: entlzprefix
    fwname: fwname
    fwsubnetprefix: fwsubnetprefix
    fwtype: fwtype
    gwname: gwname
    gwsubnetprefix: gwsubnetprefix
    gwtype: gwtype
    hubvnetname: hubvnetname
    hubvnetprefix: hubvnetprefix
  }
}

module managementsub 'platform-connectivity-vnethubspoke-modules/management-sub.bicep' ={
  name: 'managementsub'
  scope: subscription(managementsubid)
  params:{
    entlzprefix: entlzprefix
    managementsubnetprefix: managementsubnetprefix
    managementvnetname: managementvnetname
    managementvnetprefix: managementvnetprefix
  }
}

module identitysub 'platform-connectivity-vnethubspoke-modules/identity-sub.bicep' ={
  name: 'managementsub'
  scope: subscription(managementsubid)
  params:{
    entlzprefix: entlzprefix
    identitysubnetprefix: identitysubnetprefix
    identityvnetname: identityvnetname
    identityvnetprefix: identityvnetprefix
  }
}

module securitysub 'platform-connectivity-vnethubspoke-modules/security-sub.bicep' ={
  name: 'managementsub'
  scope: subscription(managementsubid)
  params:{
    entlzprefix: entlzprefix
    securitysubnetprefix: securitysubnetprefix
    securityvnetname: securityvnetname
    securityvnetprefix: securityvnetprefix
  }
}

