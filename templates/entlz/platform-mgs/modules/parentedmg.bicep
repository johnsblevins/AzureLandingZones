param name string
param parentId string

targetScope='tenant'

resource mg 'Microsoft.Management/managementGroups@2020-05-01' = {
  name: name
  properties:{
    details:{
      parent:{
        id: parentId
      }
    }
  }
}

output mgId string = mg.id
