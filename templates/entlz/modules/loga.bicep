param aaname string
param loganame string

var location = resourceGroup().location

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

resource agenthealthassessment 'Microsoft.OperationsManagement/solutions@2015-11-01-preview'={
  name: 'agenthealthassessment(${loga.name})'
  dependsOn:[
    loga
    aa
  ]
  location: location
  properties:{
    workspaceResourceId: loga.id
  }
  plan:{
    name: 'agenthealthassessment(${loga.name})'
    product: 'OMSGallery/AgentHealthAssessment'
    promotionCode: ''
    publisher: 'Microsoft'
  }
}

resource antimalware 'Microsoft.OperationsManagement/solutions@2015-11-01-preview'={
  name: 'enableAntiMalware(${loga.name})'
  dependsOn:[
    loga
    aa
  ]
  location: location
  properties:{
    workspaceResourceId: loga.id
  }
  plan:{
    name: 'antimalware(${loga.name})'
    product: 'OMSGallery/AntiMalware'
    promotionCode: ''
    publisher: 'Microsoft'
  }
}

resource activitylog 'Microsoft.OperationsManagement/solutions@2015-11-01-preview'={
  name: 'activitylog(${loga.name})'
  dependsOn:[
    loga
    aa
  ]
  location: location
  properties:{
    workspaceResourceId: loga.id
  }
  plan:{
    name: 'activitylog(${loga.name})'
    product: 'OMSGallery/AzureActivity'
    promotionCode: ''
    publisher: 'Microsoft'
  }
}

resource changetracking 'Microsoft.OperationsManagement/solutions@2015-11-01-preview'={
  name: 'changetracking(${loga.name})'
  dependsOn:[
    loga
    aa
  ]
  location: location
  properties:{
    workspaceResourceId: loga.id
  }
  plan:{
    name: 'changetracking(${loga.name})'
    product: 'OMSGallery/ChangeTracking'
    promotionCode: ''
    publisher: 'Microsoft'
  }
}

resource vminsights 'Microsoft.OperationsManagement/solutions@2015-11-01-preview'={
  name: 'vminsights(${loga.name})'
  dependsOn:[
    loga
    aa
  ]
  location: location
  properties:{
    workspaceResourceId: loga.id
  }
  plan:{
    name: 'vminsights(${loga.name})'
    product: 'OMSGallery/VMInsights'
    promotionCode: ''
    publisher: 'Microsoft'
  }
}


resource security 'Microsoft.OperationsManagement/solutions@2015-11-01-preview'={
  name: 'security(${loga.name})'
  dependsOn:[
    loga
    aa
  ]
  location: location
  properties:{
    workspaceResourceId: loga.id
  }
  plan:{
    name: 'security(${loga.name})'
    product: 'OMSGallery/Security'
    promotionCode: ''
    publisher: 'Microsoft'
  }
}

resource securityinsights 'Microsoft.OperationsManagement/solutions@2015-11-01-preview'={
  name: 'securityinsights(${loga.name})'
  dependsOn:[
    loga
    aa
  ]
  location: location
  properties:{
    workspaceResourceId: loga.id
  }
  plan:{
    name: 'securityinsights(${loga.name})'
    product: 'OMSGallery/SecurityInsights'
    promotionCode: ''
    publisher: 'Microsoft'
  }
}

resource servicemap 'Microsoft.OperationsManagement/solutions@2015-11-01-preview'={
  name: 'servicemap(${loga.name})'
  dependsOn:[
    loga
    aa
  ]
  location: location
  properties:{
    workspaceResourceId: loga.id
  }
  plan:{
    name: 'servicemap(${loga.name})'
    product: 'OMSGallery/ServiceMap'
    promotionCode: ''
    publisher: 'Microsoft'
  }
}

resource sqlassessment 'Microsoft.OperationsManagement/solutions@2015-11-01-preview'={
  name: 'sqlassessment(${loga.name})'
  dependsOn:[
    loga
    aa
  ]
  location: location
  properties:{
    workspaceResourceId: loga.id
  }
  plan:{
    name: 'sqlassessment(${loga.name})'
    product: 'OMSGallery/SqlAssessment'
    promotionCode: ''
    publisher: 'Microsoft'
  }
}

resource updatemgmt 'Microsoft.OperationsManagement/solutions@2015-11-01-preview'={
  name: 'updatemgmt(${loga.name})'
  dependsOn:[
    loga
    aa
  ]
  location: location
  properties:{
    workspaceResourceId: loga.id
  }
  plan:{
    name: 'updatemgmt(${loga.name})'
    product: 'OMSGallery/UpdateMgmt'
    promotionCode: ''
    publisher: 'Microsoft'
  }
}
