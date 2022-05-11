/* *******************
******* PARAMS *******
******************* */
@description('''
  The name of the Automation Account.

  ** Must be 6-50 lower-case alphanumeric characters or hyphens and must start with a letter and not end with a hyphen.
''')
@maxLength(50)
@minLength(6)
param autoAcctName string

@description('''
  An object that represents the required Key Vault Key attributes.

  ** Requires the following attributes: keyName, keyVersion

''')
param keyInfo object

@description('''
  An object that represents the required Key Vault attributes.

  ** Requires the following attributes: vaultName, vaultUri.
''')
param keyVaultInfo object

@description('The Azure location to deploy the resource to. Default: same location as the Resource Group being deployed to')
param location string = resourceGroup().location

@allowed([
  'Basic'
  'Free'
])
@description('Sets the SKU name for the Automation Account. Default: \'Basic\' ')
param skuName string = 'Basic'

@description('''
  A list of key value pairs that describe the resource. These tags can be used for viewing and grouping this resource (across resource groups).

  A maximum of 15 tags can be provided for a resource. Each tag must have a key with a length no greater than 128 characters and a value with a length no greater than 256 characters.  Default: empty object
''')
param tags object = {}

@description('''
  An object that represents the required user-assigned managed identity attributes. This ID will execute the Deployment Script.

  ** Requires the following attributes: id, principalId
''')
param userAssignedIdentity object

/* *******************
******** VARS ********
******************* */
var commonDeployScriptParams = '-ResourceName ${autoAcctName} -ResourceType AutomationAccount -ResourceGroupName ${resourceGroup().name} -KeyVaultName ${keyVaultInfo.vaultName} -PermsToKeys ${permsToKeys}'
var deployScriptAzPowerShellVersion = '6.6'
var deployScriptContent = loadTextContent('deploymentScripts/Set-AzResourceEncryption.ps1')
var permsToKeys = 'get,unwrapkey,wrapkey,recover'

/* *******************
****** RESOURCES *****
******************* */
module deployScript1 'deployScriptManagedId.bicep' = {
  name: 'configAutomationMsftKey'
  params: {
    arguments: commonDeployScriptParams
    azPowerShellVersion: deployScriptAzPowerShellVersion
    location: location
    scriptContent: deployScriptContent
    userAssignedIdentity: userAssignedIdentity
  }
}

resource automationAccount 'Microsoft.Automation/automationAccounts@2021-06-22' = {
  name: autoAcctName
  dependsOn: [
    deployScript1
  ]
  identity: {
    type: 'SystemAssigned'
  }
  location: location
  properties:{
    encryption: {
      keySource: 'Microsoft.Automation'
    }
    sku:{
      name: skuName
    }
  }
  tags: tags
}

module deployScript2 'deployScriptManagedId.bicep' = {
  name: 'configAutomationCmk'
  dependsOn: [
    automationAccount
  ]
  params: {
    arguments: '${commonDeployScriptParams} -KeyVaultUri ${keyVaultInfo.vaultUri} -KeyName ${keyInfo.keyName} -KeyVersion ${keyInfo.keyVersion}'
    azPowerShellVersion: deployScriptAzPowerShellVersion
    location: location
    scriptContent: deployScriptContent
    userAssignedIdentity: userAssignedIdentity
  }
}

/* *******************
******* OUTPUTS ******
******************* */
output id string = automationAccount.id
output name string = automationAccount.name
output type string = automationAccount.type
output identity object = automationAccount.identity
output deployScriptOutputs object = deployScript1.outputs.outputs
output deployScript2Outputs object = deployScript2.outputs.outputs
