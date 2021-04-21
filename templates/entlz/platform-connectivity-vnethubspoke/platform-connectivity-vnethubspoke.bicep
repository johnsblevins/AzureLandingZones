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
var bastionsubnetname = 'AzureBastionSubnet'
var ergwname = '${entlzprefix}-hub-ergw-${location}'
var fw_subnetoctets=split(split(fwsubnetprefix,'/')[0],'.')
var fw_lastoctet=string(int(fw_subnetoctets[3])+4)
var fwip=concat(fw_subnetoctets[0],'.',fw_subnetoctets[1],'.',fw_subnetoctets[2],'.',fw_lastoctet)
var fwmanagementrtname = '${hubvnetname}-fwmanagement-rt'
var fwmanagementsubnetname = 'AzureFirewallManagementSubnet'
var fwname = '${entlzprefix}-hub-fw-${location}'
var fwpolicyname = '${fwname}-policy'
var fwrtname = '${hubvnetname}-fw-rt'
var fwsubnetname = 'AzureFirewallSubnet'
var gwrtname = '${hubvnetname}-gw-rt'
var gwsubnetname = 'GatewaySubnet'
var gwtier = ( gwtype=='ExpressRoute'?'ErGw1AZ':'VpnGw2AZ' )
var hubconnectivityrgname = '${entlzprefix}-hub-connectivity-${location}'
var hubmanagementrtname = '${hubvnetname}-management-rt'
var hubmanagementsubnetname = 'HubManagement'
var hubtoidentityspokepeername = 'hub-to-identity-${location}'
var hubtomanagementspokepeername = 'hub-to-management-${location}'
var hubtosecurityspokepeername = 'hub-to-security-${location}'
var hubvnetname = '${entlzprefix}-hub-vnet-${location}'
var identityconnectivityrgname = '${entlzprefix}-identity-connectivity-${location}'
var identityspoketohubpeername = 'identity-to-hub-${location}'
var identityvnetname = '${entlzprefix}-identity-vnet-${location}'
var identityvnetrtname = '${entlzprefix}-identity-rt'
var managementconnectivityrgname = '${entlzprefix}-management-connectivity-${location}'
var managementspoketohubpeername = 'management-to-hub-${location}'
var managementvnetname = '${entlzprefix}-management-vnet-${location}'
var managementvnetrtname = '${entlzprefix}-management-rt'
var securityconnectivityrgname = '${entlzprefix}-security-connectivity-${location}'
var securityspoketohubpeername = 'security-to-hub-${location}'
var securityvnetname = '${entlzprefix}-security-vnet-${location}'
var securityvnetrtname = '${entlzprefix}-security-rt'
var vpngwname = '${entlzprefix}-hub-vpngw-${location}'

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
  dependsOn:[
    connectivitysub
  ]
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
    fwip: fwip
    spokevnetrtname: managementvnetrtname
  }
}

module identitysub 'modules/identity-sub.bicep' ={
  name: 'identitysub'
  scope: subscription(identitysubid)
  dependsOn:[
    managementsub
  ]
  params:{
    entlzprefix: entlzprefix
    identitysubnetprefix: identitysubnetprefix
    identityvnetname: identityvnetname
    identityvnetprefix: identityvnetprefix
    identityconnectivityrgname:  identityconnectivityrgname
    location: location
    hubtospokepeername: hubtoidentityspokepeername
    hubvnetname: hubvnetname
    hubvnetrgname: hubconnectivityrgname
    hubvnetsub: connectivitysubid
    spoketohubpeername: identityspoketohubpeername
    fwip: fwip
    spokevnetrtname: identityvnetrtname
  }
}


module securitysub 'modules/security-sub.bicep' ={
  name: 'securitysub'
  scope: subscription(securitysubid)
  dependsOn: [
    identitysub
  ]
  params:{
    entlzprefix: entlzprefix
    securitysubnetprefix: securitysubnetprefix
    securityvnetname: securityvnetname
    securityvnetprefix: securityvnetprefix
    securityconnectivityrgname:  securityconnectivityrgname
    location: location
    hubtospokepeername: hubtosecurityspokepeername
    hubvnetname: hubvnetname
    hubvnetrgname: hubconnectivityrgname
    hubvnetsub: connectivitysubid
    spoketohubpeername: securityspoketohubpeername
    fwip: fwip
    spokevnetrtname: securityvnetrtname
  }
}


