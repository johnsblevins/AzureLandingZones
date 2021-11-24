targetScope= 'subscription'

resource testrole 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' = {
  name: guid('testname')
  properties: {
    assignableScopes: [
      '/subscriptions/f86eed1f-a251-4b29-a8b3-98089b46ce6c'
    ]
    description: 'testdescription'
    permissions: [
    {
      actions: [
        'Microsoft.Resources/subscriptions/resourceGroups/read'
        'Microsoft.Resources/subscriptions/resourceGroups/write'
        'Microsoft.Resources/subscriptions/resourceGroups/delete'
        'Microsoft.Resources/subscriptions/resourceGroups/moveResources/action'
        'Microsoft.Resources/subscriptions/resourceGroups/validateMoveResources/action'
      ]
      notActions: []
      dataActions: []
      notDataActions: []
    }
  ]
  roleName: 'testrolename'
  type: 'customRole'
  }
}
