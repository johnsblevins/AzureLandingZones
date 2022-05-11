targetScope='resourceGroup'

resource rtbad 'Microsoft.Network/routeTables@2021-03-01'={
  name: 'rt-bad'
  location: resourceGroup().location
}
