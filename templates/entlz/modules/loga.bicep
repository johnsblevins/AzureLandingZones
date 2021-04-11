param aaname string
param loganame string

resource aa 'Microsoft.Automation/automationAccounts@2020-01-13-preview'={
  name: aaname
  location: resourceGroup().location
  properties:{
    sku:{
      name: 'Basic'
    }
  }
}
resource loga 'Microsoft.OperationalInsights/workspaces@2020-10-01'={
  location: resourceGroup().location
  name: loganame
  dependsOn:[
    aa
  ]
  properties:{
    sku:{
      name:'PerNode'
    }
    retentionInDays: 360    
  }
  resource myChild 'linkedServices@2020-08-01' ={
    name: 'Automation'
    dependsOn: [
      loga
      aa
    ]
    properties: {
      resourceId: aa.id
    }
  }
}
