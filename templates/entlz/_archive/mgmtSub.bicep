targetScope='subscription'

resource logAPolicyDefinition 'Microsoft.Authorization/policyDefinitions@2020-09-01' existing = {
  name: 'Deploy-Log-Analytics'
  scope: managementGroup('/providers/Microsoft.Management/managementgroups/jblz1')
}

resource logAPolicyAssignment 'Microsoft.Authorization/policyDefinitions@2020-09-01' existing = {
  name: 'Deploy-Log-Analytics'
  scope: managementGroup('/providers/Microsoft.Management/managementGroups/jblz1-management')
}
/*
resource remediateLogAPolicy 'Microsoft.Resources/deployments@2020-10-01' = {
  name: 'remediateLogAPolicy'
  dependsOn:[
    logAPolicyAssignment
    logAPolicyDefinition
  ]
  properties:{
    mode:'Incremental'
    template: logAPolicyDefinition.properties.policyRule.then.details.deployment.properties.template
    parameters: logAPolicyAssignment.properties.parameters
  }  
}
*/
output defid1 string = logAPolicyDefinition.properties.description
//output defid2 string = 
// output defname string = reference('/providers/Microsoft.Management/managementgroups/jblz1/providers/Microsoft.Authorization/policyDefinitions/Deploy-Log-Analytics').name
//output defname string = logAPolicyDefinition.properties.displayName
//output assname string = logAPolicyAssignment.properties.displayName
