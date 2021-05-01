param bastionname string
param bastionsubnetname string
param bastionsubnetprefix string
param entlzprefix string
param environment string
param ergwname string
param fwip string
param fwmanagementrtname string
param fwmanagementsubnetname string
param fwmanagementsubnetprefix string
param fwname string
param fwpolicyname string
param fwrtname string
param fwsubnetname string
param fwsubnetprefix string
param fwtype string
param gwrtname string
param gwsubnetname string
param gwsubnetprefix string
param gwtier string
param gwtype string
param hubconnectivityrgname string
param hubmanagementrtname string
param hubmanagementsubnetname string
param hubmanagementsubnetprefix string
param hubvnetname string
param hubvnetprefix string
param identityvnetprefix string
param location string
param logaworkspaceid string
param managementsubnetprefix string
param managementvnetprefix string
param securityvnetprefix string
param vpngwname string

targetScope='subscription'

resource hubconnectivityrg 'Microsoft.Resources/resourceGroups@2020-10-01'={
  name: hubconnectivityrgname
  location: location  
}

module hubvnet 'hub.bicep' = {
  scope: hubconnectivityrg
  dependsOn:[
    hubconnectivityrg
  ]
  name: hubvnetname
  params:{
    bastionname: bastionname
    bastionsubnetname: bastionsubnetname
    bastionsubnetprefix: bastionsubnetprefix
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
    hubmanagementrtname: hubmanagementrtname
    hubmanagementsubnetname: hubmanagementsubnetname
    hubmanagementsubnetprefix: hubmanagementsubnetprefix
    hubvnetname: hubvnetname
    hubvnetprefix: hubvnetprefix
    identityvnetprefix: identityvnetprefix
    location: location
    logaworkspaceid: logaworkspaceid
    managementvnetprefix: managementvnetprefix
    securityvnetprefix: securityvnetprefix
    vpngwname: vpngwname
  }
}
