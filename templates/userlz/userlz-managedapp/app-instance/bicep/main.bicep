targetScope = 'subscription'

//@<decorator>(<argument>)
//param <parameter-name> <parameter-data-type> = <default-value>
param randomid string = substring(uniqueString(subscription().id),0,6)
param location string = 'usgovvirginia'

resource apprg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'app-rg'
  location: location  
}

module app 'app.bicep' = {
  scope: apprg
  name: 'app'
  params:{
    
  }
}

// conditional deployment
//resource <resource-symbolic-name> '<resource-type>@<api-version>' = if (<condition-to-deploy>) {
//  <resource-properties>
//}

// iterative deployment
//@<decorator>(<argument>)
//resource <resource-symbolic-name> '<resource-type>@<api-version>' = [for <item> in <collection>: {
//  <resource-properties>
//}]

//module <module-symbolic-name> '<path-to-file>' = {
//  name: '<linked-deployment-name>'
//  params: {
//    <parameter-names-and-values>
//  }
//}

// conditional deployment
//module <module-symbolic-name> '<path-to-file>' = if (<condition-to-deploy>) {
//  name: '<linked-deployment-name>'
//  params: {
//    <parameter-names-and-values>
//  }
//}

// iterative deployment
//module <module-symbolic-name> '<path-to-file>' = [for <item> in <collection>: {
//  name: '<linked-deployment-name>'
//  params: {
//    <parameter-names-and-values>
//  }
//}]

// deploy to different scope
//module <module-symbolic-name> '<path-to-file>' = {
//  name: '<linked-deployment-name>'
//  scope: <scope-object>
//  params: {
//    <parameter-names-and-values>
//  }
//}

output <output-name> <output-data-type> = <output-value>

// iterative output
output <output-name> array = [for <item> in <collection>: {
  <output-properties>
}]
