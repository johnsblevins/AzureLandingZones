appdefRG='managed-lz-appdef'
location='usgovvirginia'
appdefSA="managedlzappdef001"
appdefContainer='appdef'
appdefZipPath='lz.zip'
appdefName='managed-lz-appdef'
appdefDisplayName='Managed Landing Zone'
appdefDescription='Deploys a managed landing zone which is connected to the on-premises network on behalf of the user.'
appAdministrators='elz2-platform-admins'

zip -rv lz.zip createUiDefinition.json mainTemplate.json

az group create --name $appdefRG --location $location

az storage account create \
    --name $appdefSA \
    --resource-group $appdefRG \
    --location $location \
    --sku Standard_LRS \
    --kind StorageV2

az storage container create \
    --account-name $appdefSA \
    --name $appdefContainer \
    --public-access blob

az storage blob upload \
    --account-name $appdefSA \
    --container-name $appdefContainer \
    --name $appdefZipPath \
    --file $appdefZipPath

groupid=$(az ad group show --group $appAdministrators --query objectId --output tsv)

ownerid=$(az role definition list --name Owner --query [].name --output tsv)

blob=$(az storage blob url --account-name $appdefSA --container-name $appdefContainer --name $appdefZipPath --output tsv)

az managedapp definition create \
  --name $appdefName \
  --location $location \
  --resource-group $appdefRG \
  --lock-level ReadOnly \
  --display-name "$appdefDisplayName" \
  --description "$appdefDescription" \
  --authorizations "$groupid:$ownerid" \
  --package-file-uri "$blob"