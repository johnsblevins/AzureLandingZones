# Login to Azure 
az cloud set -n AzureUSGovernment
az Login

# Create Azure-Platform-Owners Azure AD Group
platformOwnerGroup=$(az ad group create --display-name azure-platform-owners --mail-nickname azure-platform-owners --description "Members can Create EA Subs in the Default Management Group" --query objectId --output tsv)

# Create Azure AD App Registration and Service Principal
appId=$(az ad app create --display-name "azure-entlz-deployer" --query appId --output tsv)
sleep 15

az ad sp create --id $appId
sleep 15

objId=$(az ad sp show --id $appId --query objectId --output tsv)

# Add Service Principal to Group
az ad group member add --group $platformOwnerGroup --member-id $objId

# Assign Azure-Platform-Owners Group Owner role to Tenant Root Group Scope
az role assignment create --role "Owner" --scope / --assignee $platformOwnerGroup

echo Done