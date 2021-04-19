param spokevnetname string
param spokevnetprefix string
param managementsubnetprefix string

resource spokevnet 'Microsoft.Network/virtualNetworks@2020-08-01'= {
  name: spokevnetname
  location: resourceGroup().location
  properties:{
    addressSpace: {
      addressPrefixes: [
        spokevnetprefix   
      ]
    }    
    subnets: [
      {
        name: 'management'
        properties:{
          addressPrefix: managementsubnetprefix     
        }
      }
    ]            
  }
}

output spokevnetid string = spokevnet.id
