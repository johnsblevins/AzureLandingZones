targetScope='resourceGroup'

resource disk 'Microsoft.Compute/disks@2021-04-01' ={
  name: 'diskwithexport'
  location: resourceGroup().location    
  properties: {
    creationData: {
      createOption: 'Empty'
    }
    diskSizeGB: 4
  }
}
