# Blueprints

Getting started with Azure Blueprint development https://github.com/Azure/azure-blueprints.

* Step 1
Created User Managed Identity with contributor rights to Hub VNET (to complete Peering operation) and Owner rights to new subscription.

* Step 2
Deploy the Blueprint
Install-Module -Name Az.Blueprint
Import-AzBlueprintWithArtifact -Name fedrampmod-hubspoke -ManagementGroupId <root mg Id> -InputPath  <path to blueprint template folder> -Force

* Step 3



