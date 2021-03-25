# Create Azure AD Group
grpObjId=$(az ad group create --display-name Azure-EA-Subscription-Creators --mail-nickname Azure-EA-Subscription-Creators --description "Members can Create EA Subs in the Default Management Group" --query objectId --output tsv)

# Create Azure AD App Registration and Service Principal
appId=$(az ad app create --display-name "SPN-EA-Subscription-Creator" --query appId --output tsv)
az ad sp create --id $appId
objId=$(az ad sp show --id $appId --query objectId --output tsv)

# Add Service Principal to Group
az ad group member add --group $grpObjId --member-id $objId

# Get Enrollment Account ID and Name
enrAcctID=$(az billing enrollment-account list --query "[0].id" --output tsv) # /providers/Microsoft.Billing/enrollmentAccounts/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
enrAcctName=$(az billing enrollment-account list --query "[0].name" --output tsv) # xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

# Assign Group Owner Role to Enrollment Account
az role assignment create --assignee $grpObjId --role "Owner" --scope $enrAcctID

# Find Default Management Group for Subscription Creation
rootMG=$(az account management-group list --query "[?displayName=='Root Management Group'].name" --output tsv)
defaultMGName=$(az rest --method get --url "https://management.usgovcloudapi.net/providers/Microsoft.Management/managementGroups/$rootMG/settings/default?api-version=2020-05-01" --query properties.defaultManagementGroup --output tsv)
defaultMG=$(az account management-group list --query $"[?displayName=='"$defaultMGName"'].id" --output tsv)

# Assign Group "Management Group Contributor" role to default Management Group
az role assignment create --role "Management Group Contributor" --scope "$defaultMG" --assignee $grpObjId