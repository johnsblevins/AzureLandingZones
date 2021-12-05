param location string = 'usgovvirginia'

targetScope='subscription'

module assign 'activity-logs-to-loga-assign.bicep' = {
  name: 'deploy-activity-logs-to-loga-assign'
  params: {
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/2465583e-4e78-4c15-b6be-a36cbc7c8b0f'
    effect: 'DeployIfNotExists'
    logAnalytics: '/subscriptions/f86eed1f-a251-4b29-a8b3-98089b46ce6c/resourcegroups/defaultresourcegroup-usgv/providers/microsoft.operationalinsights/workspaces/defaultworkspace-f86eed1f-a251-4b29-a8b3-98089b46ce6c-usgv'
    location: location
  }
}
