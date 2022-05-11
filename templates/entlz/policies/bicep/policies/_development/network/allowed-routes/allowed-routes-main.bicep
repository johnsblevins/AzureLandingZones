param rgname string = 'rg-allowed-routes-test'
param location string = 'usgovvirginia'
targetScope='subscription'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01'={
  name: rgname
  location: location
}

module def 'allowed-routes-def.bicep' = {
  name: 'deploy-allowed-routes-def'
}

module assign 'allowed-routes-assign.bicep' = {
  name: 'deploy-allowed-routes-assign'
  dependsOn: [
    def
  ]
  scope: rg  
}

//module testcasegood 'test-case-good.bicep' = {
//  name: 'deploy-good-test-case'
//  dependsOn: [
//    assign
//  ]
//  scope: rg
//}
//
//module testcasebad 'test-case-bad.bicep' = {
//  name: 'deploy-bad-test-case'
//  dependsOn: [
//    assign
//  ]
//  scope: rg
//}
