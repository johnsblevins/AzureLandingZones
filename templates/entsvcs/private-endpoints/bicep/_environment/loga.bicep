param logaworkspacename string
param location string = resourceGroup().location

targetScope='resourceGroup'

resource logaworkspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview'={
  location: location
  name: logaworkspacename
  properties:{
    sku: {
      name: 'PerGB2018'
    }
  }
}
