param name string

targetScope='tenant'

resource mg 'Microsoft.Management/managementGroups@2020-05-01' = {
  name: name
}

output mgId string = mg.id
