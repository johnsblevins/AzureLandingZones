#!/bin/bash

# App Definition Variables
appdefsubid='f86eed1f-a251-4b29-a8b3-98089b46ce6c'
appdefname='managed-lz-appdef'
appdefrg='managed-lz-appdef'
appdefid=$(az managedapp definition show --name $appdefname --resource-group $appdefrg --subscription $appdefsubid --query id --output tsv)

# App Variables
subid=f86eed1f-a251-4b29-a8b3-98089b46ce6c
az account set -s $subid
subname=$(az account show --query name -o tsv)
appname="$subname-managed-lz-app"
apprg="$subname-managed-lz-rg"
managedrg="$subname-managed-lz-locked-rg"
location='usgovvirginia'
managedgroupid=/subscriptions/$subid/resourceGroups/$managedrg

# App Parameters
vnet_name="$subname-vnet"
nsg_name="$subname-nsg"
rt_name="$subname-rt"
vnet_address_space="10.0.0.0/23"
mgt_address_prefix="10.0.0.0/26"
web_address_prefix="10.0.0.64/26"
app_address_prefix="10.0.0.128/26"
data_address_prefix="10.0.0.192/26"
azure_firewall_ip="10.1.0.4"

# Create resource group
az group create --name $apprg --location $location 

# Create the managed application
az managedapp create \
  --name $appname \
  --location $location \
  --kind "Servicecatalog" \
  --resource-group $apprg \
  --managedapp-definition-id $appdefid \
  --managed-rg-id $managedgroupid \
  --parameters "{\"vnet_name\": {\"value\": \"$vnet_name\"}, \"nsg_name\": {\"value\": \"$nsg_name\"}, \"rt_name\": {\"value\": \"$rt_name\"}, \"vnet_address_space\": {\"value\": \"$vnet_address_space\"}, \"mgt_address_prefix\": {\"value\": \"$mgt_address_prefix\"}, \"web_address_prefix\": {\"value\": \"$web_address_prefix\"}, \"app_address_prefix\": {\"value\": \"$app_address_prefix\"}, \"data_address_prefix\": {\"value\": \"$data_address_prefix\"}, \"azure_firewall_ip\": {\"value\": \"$azure_firewall_ip\"}}"