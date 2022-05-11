targetScope='resourceGroup'

resource pip 'Microsoft.Network/publicIPAddresses@2021-03-01' ={
  name: 'badpipresource'
  location: resourceGroup().location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}
