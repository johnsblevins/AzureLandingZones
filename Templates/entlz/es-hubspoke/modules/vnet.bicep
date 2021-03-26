param vnetName string
param vnetPrefix string
param mgmtSubnetPrefix string
param webSubnetPrefix string
param appSubnetPrefix string
param dataSubnetPrefix string
param nsgID string
param rtID string

resource vnet 'Microsoft.Network/virtualNetworks@2020-08-01'= {
  name: '${vnetName}'
  location: resourceGroup().location
  properties:{
    addressSpace: {
      addressPrefixes: [
        vnetPrefix   
      ]
    }    
    subnets: [
      {
        name: 'mgmt'
        properties:{
          addressPrefix: mgmtSubnetPrefix     
          networkSecurityGroup:{
            id: nsgID
          }     
          routeTable: {
            id: rtID
          }
          }
      }
      {
        name: 'web'
        properties:{
          addressPrefix: webSubnetPrefix     
          networkSecurityGroup:{
            id: nsgID
          }     
          routeTable: {
            id: rtID
          }   
          }
      }
      {
        name: 'app'
        properties:{
          addressPrefix: appSubnetPrefix     
          networkSecurityGroup:{
            id: nsgID
          }     
          routeTable: {
            id: rtID
          }     
          }
      }
      {
        name: 'data'
        properties:{
          addressPrefix: dataSubnetPrefix     
          networkSecurityGroup:{
            id: nsgID
          }     
          routeTable: {
            id: rtID
          }  
          }
      }
    ]            
  }
}
