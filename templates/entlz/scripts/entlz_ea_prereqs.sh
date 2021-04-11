# Login to Azure 
az cloud set -n AzureUSGovernment
az Login

# Create Azure-EA-Subscription-Creators Azure AD Group
subCreatorGroup=$(az ad group create --display-name azure-ea-subscription-creators --mail-nickname azure-ea-subscription-creators --description "Members can Create EA Subs in the Default Management Group" --query objectId --output tsv)
sleep 15

# Add Service Principal to Group
objId=$(az ad sp list --display-name "azure-entlz-deployer" --query [].objectId --output tsv)
az ad group member add --group $subCreatorGroup --member-id $objId

# Get Enrollment Account ID and Name
enrAcctID=$(az billing enrollment-account list --query "[0].id" --output tsv) # /providers/Microsoft.Billing/enrollmentAccounts/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
enrAcctName=$(az billing enrollment-account list --query "[0].name" --output tsv) # xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

# Assign Azure-EA-Subscription-Creators Group Owner Role to Enrollment Account Scope
az role assignment create --assignee $subCreatorGroup --role "Owner" --scope $enrAcctID

echo Done