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

resource AgentHealthAssessment 'Microsoft.OperationsManagement/solutions@2015-11-01-preview'={
  name: 'AgentHealthAssessment(${loga.name})'
  dependsOn:[
    loga
    aa
  ]
  location: location
  properties:{
    workspaceResourceId: loga.id
  }
  plan:{
    name: 'AgentHealthAssessment(${loga.name})'
    product: 'OMSGallery/AgentHealthAssessment'
    publisher: 'Microsoft'
    promotionCode: ''
  }
}

resource AntiMalware 'Microsoft.OperationsManagement/solutions@2015-11-01-preview'={
  name: 'AntiMalware(${loga.name})'
  dependsOn:[
    loga
    aa
  ]
  location: location
  properties:{
    workspaceResourceId: loga.id
  }
  plan:{
    name: 'AntiMalware(${loga.name})'
    product: 'OMSGallery/AntiMalware'
    promotionCode: ''
    publisher: 'Microsoft'
  }
}

resource AzureActivity 'Microsoft.OperationsManagement/solutions@2015-11-01-preview'={
  name: 'AzureActivity(${loga.name})'
  dependsOn:[
    loga
    aa
  ]
  location: location
  properties:{
    workspaceResourceId: loga.id
  }
  plan:{
    name: 'AzureActivity(${loga.name})'
    product: 'OMSGallery/AzureActivity'
    promotionCode: ''
    publisher: 'Microsoft'
  }
}

resource ChangeTracking 'Microsoft.OperationsManagement/solutions@2015-11-01-preview'={
  name: 'ChangeTracking(${loga.name})'
  dependsOn:[
    loga
    aa
  ]
  location: location
  properties:{
    workspaceResourceId: loga.id
  }
  plan:{
    name: 'ChangeTracking(${loga.name})'
    product: 'OMSGallery/ChangeTracking'
    promotionCode: ''
    publisher: 'Microsoft'
  }
}

resource VMInsights 'Microsoft.OperationsManagement/solutions@2015-11-01-preview'={
  name: 'VMInsights(${loga.name})'
  dependsOn:[
    loga
    aa
  ]
  location: location
  properties:{
    workspaceResourceId: loga.id
  }
  plan:{
    name: 'VMInsights(${loga.name})'
    product: 'OMSGallery/VMInsights'
    promotionCode: ''
    publisher: 'Microsoft'
  }
}


resource Security 'Microsoft.OperationsManagement/solutions@2015-11-01-preview'={
  name: 'Security(${loga.name})'
  dependsOn:[
    loga
    aa
  ]
  location: location
  properties:{
    workspaceResourceId: loga.id
  }
  plan:{
    name: 'Security(${loga.name})'
    product: 'OMSGallery/Security'
    promotionCode: ''
    publisher: 'Microsoft'
  }
}

resource SecurityInsights 'Microsoft.OperationsManagement/solutions@2015-11-01-preview'={
  name: 'SecurityInsights(${loga.name})'
  dependsOn:[
    loga
    aa
  ]
  location: location
  properties:{
    workspaceResourceId: loga.id
  }
  plan:{
    name: 'SecurityInsights(${loga.name})'
    product: 'OMSGallery/SecurityInsights'
    promotionCode: ''
    publisher: 'Microsoft'
  }
}

resource ServiceMap 'Microsoft.OperationsManagement/solutions@2015-11-01-preview'={
  name: 'ServiceMap(${loga.name})'
  dependsOn:[
    loga
    aa
  ]
  location: location
  properties:{
    workspaceResourceId: loga.id
  }
  plan:{
    name: 'ServiceMap(${loga.name})'
    product: 'OMSGallery/ServiceMap'
    promotionCode: ''
    publisher: 'Microsoft'
  }
}

resource SQLAssessment 'Microsoft.OperationsManagement/solutions@2015-11-01-preview'={
  name: 'SQLAssessment(${loga.name})'
  dependsOn:[
    loga
    aa
  ]
  location: location
  properties:{
    workspaceResourceId: loga.id
  }
  plan:{
    name: 'SQLAssessment(${loga.name})'
    product: 'OMSGallery/SQLAssessment'
    promotionCode: ''
    publisher: 'Microsoft'
  }
}

resource Updates 'Microsoft.OperationsManagement/solutions@2015-11-01-preview'={
  name: 'Updates(${loga.name})'
  dependsOn:[
    loga
    aa
  ]
  location: location
  properties:{
    workspaceResourceId: loga.id
  }
  plan:{
    name: 'Updates(${loga.name})'
    product: 'OMSGallery/Updates'
    promotionCode: ''
    publisher: 'Microsoft'
  }
}

