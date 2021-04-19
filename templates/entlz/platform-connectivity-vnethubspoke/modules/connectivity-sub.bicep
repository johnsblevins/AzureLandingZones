param entlzprefix string
param environment string
param hubvnetname string
param hubvnetprefix string
param vpngwname string
param ergwname string
param gwtype string
param gwsubnetprefix string
param fwname string
param fwtype string
param fwsubnetprefix string
param fwmanagementsubnetprefix string
param bastionname string
param bastionsubnetprefix string
param identityvnetprefix string
param managementsubnetprefix string
param managementvnetprefix string
param securityvnetprefix string
param hubmanagementsubnetprefix string
param location string
param gwsubnetname string
param fwsubnetname string
param bastionsubnetname string
param fwmanagementsubnetname string
param hubmanagementsubnetname string
param gwtier string
param fwrtname string
param fwmanagementrtname string
param hubmanagementrtname string
param gwrtname string
param fwip string
param hubconnectivityrgname string


targetScope='subscription'

resource hubconnectivityrg 'Microsoft.Resources/resourceGroups@2020-10-01'={
  name: hubconnectivityrgname
  location: 'usgovvirginia'  
}

module hubvnet 'hub.bicep' = {
  scope: hubconnectivityrg
  dependsOn:[
    hubconnectivityrg
  ]
  name: hubvnetname
  params:{
    hubvnetname: hubvnetname
    hubvnetprefix: hubvnetprefix    
    gwsubnetprefix: gwsubnetprefix
    fwsubnetprefix: fwsubnetprefix
    bastionsubnetprefix: bastionsubnetprefix
    fwname: fwname
    fwtype: fwtype
    environment: environment
    fwmanagementsubnetprefix: fwmanagementsubnetprefix
    gwtype: gwtype
    vpngwname: vpngwname
    ergwname: ergwname
    identityvnetprefix: identityvnetprefix
    managementvnetprefix: managementvnetprefix
    securityvnetprefix: securityvnetprefix
    hubmanagementsubnetprefix: hubmanagementsubnetprefix
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
    location: location    
  }
}
