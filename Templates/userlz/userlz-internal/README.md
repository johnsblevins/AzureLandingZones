# Deploy Internal Facing User Landing Zone
## Overview
This solution allows you to provision an internal facing user landing zone in an enterprise environment using CICD pipeline.  The following components are included:

* Provision an EA Subscription
* Add Subscription Tags
* Move Subscription to Management Group
* Create a Budget for the Subscription
* Assign RBAC Roles at Subscription Level
* Deploy Internal Landing Zone Configuration

For organizations who have not already deployed their Enterprise Landing Zone scaffolding it is recommended to use the Enterprise Scale Landing Zone (EntLZ) templates [HERE](../../entlz/README.md) to deploy the framework needed for managing Azure at scale before deploying user landing zones. The enterprise scaffolding which includes a Management Group for onboarding new subs, Management Groups for Internal Production and Non-Production subs and the default infrastructure components including VNET with Hub Peering, User Defined Routes and NSGs to enforce internal connectivity requirements.  

For organizations who have already deployed their Enterprise landing zone scaffolding the following components should be added to your existing CICD pipeline deployment to enable the solution.

After the enterprise scaffolding is in place the following pre-built pipelines exist for deploying internal facing user landing zones into the enterprise landing zone:

* GitHub Action - [es-hubspoke-userlz-internal.yml](../../../.github/workflows/es-hubspoke-userlz-internal.yml)

## Prereqs
### Grant Rights for Service Principal to Create EA Subscriptions
A service principal with "Owner" rights to the enrollment account scope (/providers/Microsoft.Billing/enrollmentAccounts/) and "Management Group Contributor" rights to your MG hierarchy is needed to programatically create and manage EA subscriptions. 

The following script demonstrates how to create a Service Prinicipal, add it to an Azure Active Directory Group and grant the required rights for that group to create subscriptions.

```
# Create Azure AD Group
grpObjId=$(az ad group create --display-name Azure-EA-Subscription-Creators --mail-nickname Azure-EA-Subscription-Creators --description "Members can Create EA Subs in the Default Management Group" --query objectId --output tsv)

# Create Azure AD App Registration and Service Principal
appId=$(az ad app create --display-name "Azure-EA-Subscription-Deployer" --query appId --output tsv)
sleep 5
az ad sp create --id $appId
sleep 5
objId=$(az ad sp show --id $appId --query objectId --output tsv)

# Add Service Principal to Group
az ad group member add --group $grpObjId --member-id $objId

# Get Enrollment Account ID and Name
enrAcctID=$(az billing enrollment-account list --query "[0].id" --output tsv) # /providers/Microsoft.Billing/enrollmentAccounts/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
enrAcctName=$(az billing enrollment-account list --query "[0].name" --output tsv) # xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

# Assign Group Owner Role to Enrollment Account
az role assignment create --assignee $grpObjId --role "Owner" --scope $enrAcctID

# Assign Group "Management Group Contributor" role to Root Management Group
rootMG=$(az account management-group list --query "[?displayName=='Root Management Group'].id" --output tsv)

az role assignment create --role "Management Group Contributor" --scope "$rootMG" --assignee $grpObjId
```

# Pipeline Components
## Provision EA Subscription
The API documented [HERE](https://docs.microsoft.com/en-us/azure/cost-management-billing/manage/programmatically-create-subscription-preview?tabs=rest) is used to create the EA subscription.  Ensure you are using the **2019-10-01-preview** version of the API when making the call for it to work properly.  

The following script demonstrates how to create the EA subscription:

```
# Object Id of User, Group or Service Principal of subsciption owner
subOwnerObjId="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" 

# Subscription Name to Provision
subName="SubName"

# Offer Type - MS-AZR-USGOV-0017P for Azure Government EA
offerType="MS-AZR-USGOV-0017P"

# Enrollment Account Name

# The following command can be used to get the Enrollment Account name
# az billing enrollment-account list --query "[0].name" --output tsv
enrAcctName="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"  

# REST Call to Create Subscription
az rest --method post \
--url "https://management.usgovcloudapi.net/providers/Microsoft.Billing/enrollmentAccounts/$enrAcctName/providers/Microsoft.Subscription/createSubscription?api-version=2019-10-01-preview" \
--headers "{\"content-type\":\"application/json\"}" \
--body "{\"displayName\": \"$subName\", \"offerType\": \"$offerType\", \"owners\": [{\"objectId\": \"$subOwnerObjId\"}]}"
```

## Add Subscription Tags
It is recommend to develop a global tagging strategy which employess Azure Policy to propagate tags from Management Groups, Subscriptions and Resource Groups down to resources.  This can be accomplished with Azure Policy enforcement.  

The following script demonstrates how to write tags to the subscription once it's created: 
```
NOW=$(date +"%m/%d/%Y_%I:%M:%S_%p")
USER=$(az ad signed-in-user show --query userPrincipalName --output tsv)
OWNER=$(az ad user show --id ${{ USERLZ_SUB_OWNER_OBJECT_ID }} )
az tag create --resource-id /subscriptions/${{ USERLZ_SUBNAME }} --tags createdOn="$NOW" createdBy="$USER" owner="$OWNER" 
```

## Move Subscription to Managment Group
It is recommended to specify a "Staging" management group as the default for new subscriptions and apply required subscription level policies.  This allows for Azure Policy to apply effects at sub creation time and remove the requirement to run manual remediation tasks afterward (ex. enforce activity collection to LogA).   

The following script demonstrates how to move a subscription to a different management group: 
```
az account management-group subscription add --name "${{ USERLZ_MANAGEMENT_GROUP }}" \
--subscription ${{ secrets.USERLZ_SUBNAME }}
```

## Create Subscription Budget

```
az consumption budget create --amount $amount --budget-name $name
                             --category {cost, usage}
                             --end-date
                             --start-date
                             --time-grain {annually, monthly, quarterly}
                             [--meter-filter]
                             [--resource-filter]
                             [--resource-group]
                             [--resource-group-filter]
                             [--subscription]
```

## Assign Subscription RBAC
It is recommend to develop a global rbac strategy which employs Azure RBAC Roles, Azure AD Groups and Management Groups to enforce required roles at different MG scopes. 

The following script will create a RBAC role assignment at the subscription level:
```
az role assignment create --assignee "{assignee}" \
--role "{roleNameOrId}" \
--subscription "{subscriptionNameOrId}"
```

## User Landing Zone Deployment
A subscription level deployment can be created to stage required user landing zone resources before handing over the landing zone to users.  

The following script demonstrates the deployment of a Bicep template which creates a locked RG with Route Table, NSG, Key Vault and Disk Encryption set and connectivity RG with VNET, subnets and peerings to hub:
```
az deployment sub create -f Templates/userlz/userlz-internal/templates/main.bicep -l ${{ secrets.USERLZ_LOCATION }} -p programName=${{ secrets.USERLZ_PROGRAM_NAME }} \
#                programType=${{ secrets.USERLZ_PROGRAM_TYPE }} programEnv=${{ secrets.USERLZ_PROGRAM_ENV }} vnetPrefix= ${{ secrets.USERLZ_VNET_PREFIX }} \
#                mgmtSubnetPrefix=${{ secrets.MGMT_SUBNET_PREFIX }} webSubnetPrefix= ${{ secrets.USERLZ_WEB_SUBNET_PREFIX  }} \
#                appSubnetPrefix=${{ secrets.APP_SUBNET_PREFIX }} dataSubnetPrefix=${{ secrets.DATA_SUBNET_PREFIX }} firewallIP=${{ secrets.FIREWALL_IP }}
```


