randomid=$RANDOM
location='usgovvirginia'
rg="app-defs-rg-$randomid"
saname="appdefsa$randomid"
localpath='userlz-appdef'
appname='userlz'
groupname='userlz-admins'

zip -j app.zip $localpath/createUiDefinition.json $localpath/mainTemplate.json

az group create --name $rg --location $location

az storage account create \
    --name $saname \
    --resource-group $rg \
    --location $location \
    --sku Standard_LRS \
    --kind StorageV2

az storage container create \
    --account-name $saname \
    --name appcontainer \
    --public-access blob

az storage blob upload \
    --account-name $saname \
    --container-name appcontainer \
    --name "app.zip" \
    --file "app.zip"

rm -f app.zip

# Group, User or Application for managing the resources deployed by the Managed Application
groupid=$(az ad group show --group $groupname --query objectId --output tsv)

# Role definition ID of the Azure built-in role you want to grant access to the user, user group, or application
ownerid=$(az role definition list --name Owner --query [].name --output tsv)

# 
blob=$(az storage blob url --account-name $saname --container-name appcontainer --name app.zip --output tsv)

az managedapp definition create \
  --name $appname \
  --location $location \
  --resource-group $rg \
  --lock-level ReadOnly \
  --display-name "Managed User Landing Zone" \
  --description "Managed User Landing Zone" \
  --authorizations "$groupid:$ownerid" \
  --package-file-uri "$blob"