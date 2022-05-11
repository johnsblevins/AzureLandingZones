
param userassignedidentityname string
param location string = resourceGroup().location

targetScope='resourceGroup'

resource userassignedidentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: userassignedidentityname
  location: location
}

output principalId string = userassignedidentity.properties.principalId
