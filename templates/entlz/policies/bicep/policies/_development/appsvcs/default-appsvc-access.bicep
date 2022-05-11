targetScope='subscription'

resource def 'Microsoft.Authorization/policyDefinitions@2021-06-01'={
  name: 'appsvc-access-restrictions'
  properties:{
    displayName: 'App Service Access Restrictions'
    description: 'Restricts Access to App Services'
    policyRule: {
      if: {
        field: 'type'
        equals: 'Microsoft.Web/sites'
      }
      then: {
        effect: 'append'
        details: [
          {
            field: 'Microsoft.Web/sites/config/web.ipSecurityRestrictions[*]'                    
            value: {
              ipAddress: '0.0.0.0/0'
              action: 'Deny'
              tag: 'Default'
              priority: 599999999
              name: 'Deny All'
              description: 'Deny All'
            }            
          }
          {
            field: 'Microsoft.Web/sites/config/web.scmIpSecurityRestrictions[*]'
            value: {
              ipAddress: '0.0.0.0/0'
              action: 'Deny'
              tag: 'Default'
              priority: 599999999
              name: 'Deny All'
              description: 'Deny All'
            }
          } 
        ]
      }
    }
  }
}

resource assign 'Microsoft.Authorization/policyAssignments@2021-06-01'={
  name: 'default-appsvc-access'
  properties: {
    displayName: 'default-appsvc-access'
    policyDefinitionId: def.id
  }
}
