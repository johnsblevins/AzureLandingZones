param bastionsubnetprefix string
param connectivitysubid string
param entlzprefix string
param environment string
param fwmanagementsubnetprefix string
param fwsubnetprefix string
param fwtype string
param gwsubnetprefix string
param gwtype string
param hubmanagementsubnetprefix string
param hubvnetprefix string
param identitysubid string
param identitysubnetprefix string
param identityvnetprefix string
param location string
param managementsubid string
param managementsubnetprefix string
param managementvnetprefix string
param securitysubid string
param securitysubnetprefix string
param securityvnetprefix string
param logaworkspaceid string

targetScope='managementGroup'

var bastioname = '${entlzprefix}-hub-bastion-${location}'
var fwname = '${entlzprefix}-hub-fw-${location}'
var managementvnetname = '${entlzprefix}-management-vnet-${location}'
var identityvnetname = '${entlzprefix}-identity-vnet-${location}'
var securityvnetname = '${entlzprefix}-security-vnet-${location}'
var vpngwname = '${entlzprefix}-hub-vpngw-${location}'
var ergwname = '${entlzprefix}-hub-ergw-${location}'
var hubvnetname = '${entlzprefix}-hub-vnet-${location}'
var gwsubnetname = 'GatewaySubnet'
var fwsubnetname = 'AzureFirewallSubnet'
var bastionsubnetname = 'AzureBastionSubnet'
var fwmanagementsubnetname = 'AzureFirewallManagementSubnet'
var hubmanagementsubnetname = 'HubManagement'
var gwtier = ( gwtype=='ExpressRoute'?'ErGw1AZ':'VpnGw2AZ' )
var fwrtname = '${hubvnetname}-fw-rt'
var fwmanagementrtname = '${hubvnetname}-fwmanagement-rt'
var hubmanagementrtname = '${hubvnetname}-management-rt'
var gwrtname = '${hubvnetname}-gw-rt'
var fwsubnetoctets=split(split(fwsubnetprefix,'/')[0],'.')
var fwlastoctet=string(int(fwsubnetoctets[3])+4)
var fwip=concat(fwsubnetoctets[0],'.',fwsubnetoctets[1],'.',fwsubnetoctets[2],'.',fwlastoctet)
var hubconnectivityrgname = '${entlzprefix}-hub-connectivity-${location}'
var managementconnectivityrgname = '${entlzprefix}-management-connectivity-${location}'
var fwpolicyname = '${fwname}-policy'
var hubtomanagementspokepeername = 'hub-to-management-${location}'
var managementspoketohubpeername = 'management-to-hub-${location}'

module connectivitysub 'modules/connectivity-sub.bicep' ={
  name: 'connectivitysub'
  scope: subscription(connectivitysubid)
  params:{
    bastionname: bastioname
    bastionsubnetprefix: bastionsubnetprefix
    entlzprefix: entlzprefix
    fwname: fwname
    fwsubnetprefix: fwsubnetprefix
    fwtype: fwtype
    vpngwname: vpngwname
    ergwname: ergwname
    gwsubnetprefix: gwsubnetprefix
    gwtype: gwtype
    hubvnetname: hubvnetname
    hubvnetprefix: hubvnetprefix
    environment: environment
    fwmanagementsubnetprefix: fwmanagementsubnetprefix
    hubmanagementsubnetprefix: hubmanagementsubnetprefix
    identityvnetprefix: identityvnetprefix
    managementsubnetprefix: managementsubnetprefix
    managementvnetprefix: managementvnetprefix
    securityvnetprefix: securityvnetprefix
    location: location
    gwsubnetname: gwsubnetname
    fwsubnetname: fwsubnetname
    bastionsubnetname: bastionsubnetname
    fwmanagementsubnetname: fwmanagementsubnetname
    hubmanagementsubnetname: hubmanagementsubnetname
    gwtier: gwtier
    fwrtname: fwrtname
    fwmanagementrtname: fwmanagementrtname
    hubmanagementrtname: hubmanagementrtname
    gwrtname: gwrtname
    fwip: fwip
    hubconnectivityrgname: hubconnectivityrgname
    fwpolicyname: fwpolicyname
    logaworkspaceid: logaworkspaceid
  }
}

module managementsub 'modules/management-sub.bicep' ={
  name: 'managementsub'
  scope: subscription(managementsubid)
  params:{
    entlzprefix: entlzprefix
    managementsubnetprefix: managementsubnetprefix
    managementvnetname: managementvnetname
    managementvnetprefix: managementvnetprefix
    managementconnectivityrgname:  managementconnectivityrgname
    location: location
    hubtospokepeername: hubtomanagementspokepeername
    hubvnetname: hubvnetname
    hubvnetrgname: hubconnectivityrgname
    hubvnetsub: connectivitysubid
    spoketohubpeername: managementspoketohubpeername
  }
}
/*
module identitysub 'modules/identity-sub.bicep' ={
  name: 'identitysub'
  scope: subscription(identitysubid)
  params:{
    entlzprefix: entlzprefix
    identitysubnetprefix: identitysubnetprefix
    identityvnetname: identityvnetname
    identityvnetprefix: identityvnetprefix
  }
}

module securitysub 'modules/security-sub.bicep' ={
  name: 'securitysub'
  scope: subscription(securitysubid)
  params:{
    entlzprefix: entlzprefix
    securitysubnetprefix: securitysubnetprefix
    securityvnetname: securityvnetname
    securityvnetprefix: securityvnetprefix
  }
}

*/
