# FedRAMP Moderate App Landing Zone Blueprint
This solution contains an Azure Blueprint definition which deploys an App Landing zone with connectivity to Hub VNET and forced routing through an Azure Firewall.

![FedRAMP Moderate](./media/fedrampmodlz.png)

Getting started with Azure Blueprint development https://github.com/Azure/azure-blueprints.

## Prereqs
The Blueprint requires a user managed identity with contributor rights to Hub VNET (to complete Peering operation) and Owner rights to new subscription.

## Step 1
The Blueprint should be deployed with PowerShell.

login-azaccount -environment AzureUSGovernment

Install-Module -Name Az.Blueprint

Import-AzBlueprintWithArtifact -Name fedrampmodlz -ManagementGroupId "insert id" -InputPath  "insert path" -Force

## Step 2 - Create Subscription
Create new subscription in the appropriate Enterprise Scale management group.

## Step 3 - Assign Blueprint to subscription
Assign Blueprint to subscription.


