targetScope='resourceGroup'

resource avset 'Microsoft.Compute/availabilitySets@2021-07-01' ={
  name: 'allowedavset'
  location: resourceGroup().location  
}
