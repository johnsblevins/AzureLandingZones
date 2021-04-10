# Login to Azure 
az cloud set -n AzureUSGovernment
az Login

# Create Azure-Platform-Owners Azure AD Group
graphURI=$(az cloud show --query endpoints.microsoftGraphResourceId --output tsv)
platformOwnerGroup=$(az rest --method post \
    --url "${graphURI}beta/groups" \
    --headers "{\"content-type\":\"application/json\"}" \
    --body "{   \"description\": \"Members can Create EA Subs in the Default Management Group\", 
                \"displayName\": \"azure-platform-owners\", 
                \"isAssignableToRole\": \"false\", 
                \"mailNickname\": \"azure-platform-owners\",
                \"mailEnabled\": \"false\",
                \"securityEnabled\": \"true\",
                \"visibility\": \"Private\"
            }" \
    --query id \
    --output tsv)

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

# Assign azure-entlz-deployer Service Principal Global Reader role in AAD
az rest --method post \
    --url "${graphURI}beta/roleManagement/directory/roleAssignments" \
    --headers "{\"content-type\":\"application/json\"}" \
    --body "{   \"principalId\": \"$objId\", 
                \"roleDefinitionId\": \"f2ef992c-3afb-46b9-b7cf-a126ee74c451\", 
                \"directoryScopeId\": \"/\"
            }"

echo Done