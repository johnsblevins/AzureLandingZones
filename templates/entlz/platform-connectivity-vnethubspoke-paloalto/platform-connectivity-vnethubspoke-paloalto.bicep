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
param logaworkspaceid string
param managementsubid string
param managementsubnetprefix string
param managementvnetprefix string
param securitysubid string
param securitysubnetprefix string
param securityvnetprefix string
param randomid string = uniqueString(utcNow())

targetScope='managementGroup'

var bastioname = '${entlzprefix}-hub-bastion-${location}'
var bastionsubnetname = 'AzureBastionSubnet'
var ergwname = '${entlzprefix}-hub-ergw-${location}'
var fw_subnetoctets=split(split(fwsubnetprefix,'/')[0],'.')
var fw_lastoctet=string(int(fw_subnetoctets[3])+4)
var fwip=concat(fw_subnetoctets[0],'.',fw_subnetoctets[1],'.',fw_subnetoctets[2],'.',fw_lastoctet)
var fwmanagementrtname = '${hubvnetname}-fwmanagement-rt-${location}'
var fwmanagementsubnetname = 'AzureFirewallManagementSubnet'
var fwname = '${entlzprefix}-hub-fw-${location}'
var fwpolicyname = '${fwname}-policy'
var fwrtname = '${hubvnetname}-fw-rt-${location}'
var fwsubnetname = 'AzureFirewallSubnet'
var gwrtname = '${hubvnetname}-gw-rt-${location}'
var gwsubnetname = 'GatewaySubnet'
var gwtier = ( gwtype=='ExpressRoute'?'ErGw1AZ':'VpnGw2AZ' )
var hubconnectivityrgname = '${entlzprefix}-hub-connectivity-${location}'
var hubmanagementrtname = '${entlzprefix}-management-rt-${location}'
var hubmanagementsubnetname = 'HubManagement'
var hubtoidentityspokepeername = 'hub-to-identity-${location}'
var hubtomanagementspokepeername = 'hub-to-management-${location}'
var hubtosecurityspokepeername = 'hub-to-security-${location}'
var hubvnetname = '${entlzprefix}-hub-vnet-${location}'
var identityconnectivityrgname = '${entlzprefix}-identity-connectivity-${location}'
var identityspoketohubpeername = 'identity-to-hub-${location}'
var identityvnetname = '${entlzprefix}-identity-vnet-${location}'
var identityvnetrtname = '${entlzprefix}-identity-rt-${location}'
var identityvnetnsgname = '${entlzprefix}-identity-nsg-${location}'
var managementconnectivityrgname = '${entlzprefix}-management-connectivity-${location}'
var managementspoketohubpeername = 'management-to-hub-${location}'
var managementvnetname = '${entlzprefix}-management-vnet-${location}'
var managementvnetrtname = '${entlzprefix}-management-rt-${location}'
var managementvnetnsgname = '${entlzprefix}-management-nsg-${location}'
var securityconnectivityrgname = '${entlzprefix}-security-connectivity-${location}'
var securityspoketohubpeername = 'security-to-hub-${location}'
var securityvnetname = '${entlzprefix}-security-vnet-${location}'
var securityvnetrtname = '${entlzprefix}-security-rt-${location}'
var securityvnetnsgname = '${entlzprefix}-security-nsg-${location}'
var vpngwname = '${entlzprefix}-hub-vpngw-${location}'
var fwcount = 1
var offer = 'vmseries-flex'
var publisher = 'paloaltonetworks'
var sku = 'bundle2' // Options: byol, bundle1, bundle2
var version = '10.0.0' // Options: 9.1.3, 10.0.0, latest
var vmsize = 'Standard_DS3_v2' // Options:  Standard_D3,Standard_D4,Standard_D3_v2,Standard_D4_v2,Standard_A4,Standard_DS3_v2,Standard_DS4_v2

module connectivitysub 'modules/connectivity-sub.bicep' ={
  name: 'connectivitysub-${randomid}'
  scope: subscription(connectivitysubid)
  params:{    
    bastionname: bastioname
    bastionsubnetname: bastionsubnetname
    bastionsubnetprefix: bastionsubnetprefix
    entlzprefix: entlzprefix
    environment: environment
    ergwname: ergwname
    fwip: fwip
    fwmanagementrtname: fwmanagementrtname
    fwmanagementsubnetname: fwmanagementsubnetname
    fwmanagementsubnetprefix: fwmanagementsubnetprefix
    fwname: fwname
    fwpolicyname: fwpolicyname
    fwrtname: fwrtname
    fwsubnetname: fwsubnetname
    fwsubnetprefix: fwsubnetprefix
    fwtype: fwtype
    gwrtname: gwrtname
    gwsubnetname: gwsubnetname
    gwsubnetprefix: gwsubnetprefix
    gwtier: gwtier
    gwtype: gwtype
    hubconnectivityrgname: hubconnectivityrgname
    hubmanagementrtname: hubmanagementrtname
    hubmanagementsubnetname: hubmanagementsubnetname
    hubmanagementsubnetprefix: hubmanagementsubnetprefix
    hubvnetname: hubvnetname
    hubvnetprefix: hubvnetprefix
    identityvnetprefix: identityvnetprefix
    location: location
    logaworkspaceid: logaworkspaceid
    managementsubnetprefix: managementsubnetprefix
    managementvnetprefix: managementvnetprefix
    securityvnetprefix: securityvnetprefix
    vpngwname: vpngwname
    offer: offer
    publisher: publisher
    sku: sku
    version: version
    vmsize: vmsize
    fwcount: fwcount
  }
}

module managementsub 'modules/management-sub.bicep' ={
  name: 'managementsub-${randomid}'
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
    spokevnetnsgname: managementvnetnsgname
  }
}

module identitysub 'modules/identity-sub.bicep' ={
  name: 'identitysub-${randomid}'
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
    spokevnetnsgname: identityvnetnsgname
  }
}


module securitysub 'modules/security-sub.bicep' ={
  name: 'securitysub-${randomid}'
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
    spokevnetnsgname: securityvnetnsgname
  }
}


