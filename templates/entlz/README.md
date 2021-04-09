# Deploy Enterprise Landing Zone

The Enterprise Landing Zone architecture is modular by design and allows organizations to start with a foundational landing zone that supports their application portfolios.  The reference architecture provides for both VNET and VWAN hub-and-spoke transit models and support for both ExpressRoute and VPN hybrid connetivity models.  A policy-based governance model is enforced that can be managed at scale through Policy-as-Code and additional compliance frameworks can be layered on top of the base deployment where needed.  The architecture provides a scale mechanism for enabling mission owner workloads and can scale to support multi-tenant, multi-region and multi-sovereign deployments.

![CAF Enterprise Scale](media/cafentscale.png)

The Enterprise Landing Zone deploys the scaffolding needed to support User Landing Zones for which subscriptions are utilized as the scale unit.  The solution includes a "Subscription Vending" service which enable the automatic deployment and configuration of subscription through a CICD build and release pipeline.  The following User Landing Zones are included out-of-the-box with the Enterprise Landing Zone framework:

* Internal - Workloads requiring internal organization connectivity with high security controls
    * Production - LOB Apps, Infrastructure, Internal Business Systems, etc...
    * Non-Production - Dev, Staging, Integration, etc...
* External - Workloads not requiring internal organization connectivity with moderate security controls
    * Production - Public Facing Websites, CDN, Media Services, etc...
    * Non-Production - Dev, Staging, Integration, etc...
* Sandbox - Workloads not requiring internal organization connectivity with complete isolation and low security controls
    * Sandbox - Training, Evaluation, Testing, Playground, etc...

This repository contains CICD automation to deploy these user landing zones within the enterprise scaffolding.

## Please NOTE this is a Custom Solution Repository
The reference implementation for this solution is based on the CAF enterprise scale landing zone templates which can be found on GitHub at https://github.com/Azure/Enterprise-Scale/tree/main/docs/reference/adventureworks.  The version contained in this repository includes updates to the original templates, as well as an added set of CICD pipeline templates for GitHub and GitLab deployments as well as converted BICEP template files for use by DevOps teams to customize the solution and make the deployment repeatable and more manageable in their environment.  It also includes modifications for deployment of the template in Microsoft Azure Government (MAG).

# Deploy the Enterprise Landing Zone
## Prerequistes
1. Login to the Azure Portal with an account that has the "Global Administrator" role in Azure Active Directory.  In the Azure Active Directory blade select properties and then select "Yes" for the option to enable "Access management for Azure resources" and click Save.  This grants the "User Access Administrator" role to the logged in user at the tenant root (/) scope.

![](media/aad_props.png)

2. Create a Service Principal and Assign Azure Roles

The following script creates an **"azure-platform-owners"** group and an application registration called **"azure-entlz-deployer"** in Azure Active Directory with an associated service principal.  The app registration is added to the group and the group is assigned the "Owner" role at the tenant root (/) scope.  Afterward you will need to manually generate a secret for the app registration and make note of the Application (client) ID and Directory (tenant) ID.  The script can be run from a cloud shell instance in the Azure Portal or from a local Azure CLI instance.

```
# Create Azure-Platform-Owners Azure AD Group
platformOwnerGroup=$(az ad group create --display-name azure-platform-owners --mail-nickname azure-platform-owners --description "Members can Create EA Subs in the Default Management Group" --query objectId --output tsv)

# Create Azure AD App Registration and Service Principal
appId=$(az ad app create --display-name "azure-entlz-deployer" --query appId --output tsv)
sleep 10
az ad sp create --id $appId
sleep 10
objId=$(az ad sp show --id $appId --query objectId --output tsv)

# Add Service Principal to Group
az ad group member add --group $platformOwnerGroup --member-id $objId

# Assign Azure-Platform-Owners Group Owner role to Tenant Root Group Scope
az role assignment create --role "Owner" --scope / --assignee $platformOwnerGroup

echo Done
```

3. (OPTIONAL BUT HIGHLY RECOMMENDED) Assign EA Roles for Sub Creation

It is recommended to grant the "azure_entlz_deployer" service principal the necessary permissions to create EA subscriptions needed for the Enterprise Landing Zone components.  The standard EntLZ deployment requires four subscriptions (Management, Connectivity, Identity and Security) and while these subscriptions can be created manually the solution allows for the automatic "vending" of the required subscriptions which configures the proper name, management group, tags and policies from subscrition inception.  An account with "Enrollment Account Administrator" rights in the EA portal is required to grant this permission.  The following script creates an "Azure-EA-Subscription-Creators" group and adds the service principal:

```
# Create Azure-EA-Subscription-Creators Azure AD Group
subCreatorGrp=$(az ad group create --display-name Azure-EA-Subscription-Creators --mail-nickname Azure-EA-Subscription-Creators --description "Members can Create EA Subs in the Default Management Group" --query objectId --output tsv)

# Add Service Principal to Group
az ad group member add --group $subCreatorGrp --member-id $objId

# Get Enrollment Account ID and Name
enrAcctID=$(az billing enrollment-account list --query "[0].id" --output tsv) # /providers/Microsoft.Billing/enrollmentAccounts/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
enrAcctName=$(az billing enrollment-account list --query "[0].name" --output tsv) # xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

# Assign Azure-EA-Subscription-Creators Group Owner Role to Enrollment Account Scope
az role assignment create --assignee $subCreatorGrp --role "Owner" --scope $enrAcctID
```
## Pipeline 1 - Deploy Platform Managment Groups
In this step the following management group structure is created using the EntLZ Prefix parameter.  In the sample below "CAF" is used as the prefix identifier:

    Tenant (/)
        Tenant Root Group
            CAF (Root)
                CAF-Platform
                    CAF-Management
                    CAF-Identity
                    CAF-Connectivity
                    CAF-Security
                CAF-LandingZones
                    CAF-Internal
                        CAF-Internal-Prod
                        CAF-Internal-NonProd
                    CAF-External
                        CAF-External-Prod
                        CAF-External-NonProd
                CAF-Decomissioned
                CAF-Onboarding
                CAF-Sandboxes
                    CAF-Sandbox-Management
                    CAF-Sandbox-LandingZones

In addition, the Management Group Hierarchy settings are configured such that the "CAF-Onboarding" management group is configured as the default management group for new subscriptions and RBAC for the Management Group hierarchy is set to require "Management Group Contributor" role to add/remove/modify management groups.  This prevents non-privileged users from making changes to the management group hierarchy or creating their own branches.

The following script is used for this step:
```
# BICEP Template Deployment to Create the Management Group Hierarchy
az deployment tenant create --name "EntScale-Mgs-${{ secrets.ENTLZ_LOCATION }}" --location ${{ secrets.ENTLZ_LOCATION }} \
--template-file templates/entlz/es-hubspoke/mgmtGroups.bicep --parameters \
entLZPrefix=${{ secrets.ENTLZ_ENTERPRISE_SCALE_COMPANY_PREFIX }}

# Management Group Hierarchy Settings
TenantRootMG=$(az account management-group list --query "[0].name" --output tsv)
resourceManagerURI=$(az cloud show --query 'endpoints.resourceManager' -o tsv)
az rest --method put --headers "{\"Content-Type\":\"application/json\"}" --uri "${resourceManagerURI}providers/Microsoft.Management/managementGroups/$TenantRootMG/settings/default?api-version=2020-05-01" --body "{\"properties\": {\"defaultManagementGroup\": \"/providers/Microsoft.Management/managementGroups/${{ secrets.ENTLZ_ENTERPRISE_SCALE_COMPANY_PREFIX }}-onboarding\",\"requireAuthorizationForGroupCreation\": \"true\"}}" 
```

## Pipeline 2 - Deploy Platform Policies
In this step Azure Policies and Policy Initiatives are created and assigned to the management group hierarchy using a Policy-as-Code approach as outlined at [https://docs.microsoft.com/en-us/azure/governance/policy/concepts/policy-as-code](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/policy-as-code).  The following folder structure is used to store custom policy and initiative definitions as well as both builtin and custom policy and initiative assignments.  This is the native format when exporting policy definitions and assignements using the portal export features which allows an administrator to build a policy set within the portal and export it into the folder structure.

        .policies
        |- assignmenttemplates _______________          # Sample Assignment templates
        |  |- policy/                                   # Subfolder for Policy Template
        |     |- assign.PolicyName_Identifier.json      # Template definition for Policy
        |  |- initiative/                               # Subfolder for Initiative Template
        |     |- assign.InitiativeName_Identifier.json  # Template definition for Initiative        
        |- policies/  ________________________          # Root folder for policy resources
        |  |- policy1/  ______________________          # Subfolder for a policy
        |     |- policy.json _________________          # Policy definition
        |     |- assign.<name1>.json _________          # Assignment 1 for this policy definition
        |     |- assign.<name2>.json _________          # Assignment 2 for this policy definition
        |  |- policy2/  ______________________          # Subfolder for a policy
        |     |- policy.json _________________          # Policy definition
        |     |- assign.<name1>.json _________          # Assignment 1 for this policy definition
        |     |- assign.<name2>.json _________          # Assignment 2 for this policy definition
        |- initiatives/ ______________________          # Root folder for initiatives
        |  |- init1/ _________________________          # Subfolder for an initiative
        |     |- policyset.json ______________          # Initiative definition
        |     |- assign.<name1>.json _________          # Assignment 1 for this policy initiative
        |     |- assign.<name2>.json _________          # Assignment 2 for this policy initiative
        |  |- init2/ _________________________          # Subfolder for an initiative
        |     |- policyset.json ______________          # Initiative definition
        |     |- assign.<name1>.json _________          # Assignment 1 for this policy initiative
        |     |- assign.<name2>.json _________          # Assignment 2 for this policy initiative

The Policy-as-Code pipeline deployment consists of four steps:
* Policy Definition Creation
* Initiative Definiton Creation
* Policy Assignment
* Initiative Assignment

During the Policy Definition Creation step the pipeline loops through all policy.json files within the hierarchy and deploys the associated policy definition to the designated Management Group, which is by default the EntLZ root MG.  During the Initiative Definition Creation step the pipeline loops through all policyset.json files within the hierarchy and deploys the associated initiative definiton to the designated Management Group, which is by default the EntLZ root MG.

This pipeline can be used after the initial Enterprise Landing Zone deployment to manage Policy Defintions and Assignments going forward within the environment.

```
# Deploy Policy Definitions
for f in $(find templates/entlz/es-hubspoke/policies/policies -name policy.json); \
do name=`jq -r .name $f`; \
description=`jq -r .properties.description $f`; \
displayName=`jq -r .properties.displayName $f`; \
rules=`jq -r .properties.policyRule $f`; \
params=`jq -r .properties.parameters $f`; \
mode=`jq -r .properties.mode $f`; \
az policy definition create --name "$name" --description "$description" --display-name "$displayName" --rules "$rules" --params "$params" --management-group "jblz1" --mode "$mode"   ;\
done

# Deploy Initiative Definitions
for f in $(find templates/entlz/es-hubspoke/policies/initiatives -name policyset.json); \
do name=`jq -r .name $f`; \
description=`jq -r .properties.description $f`; \
displayName=`jq -r .properties.displayName $f`; \
definitions=`jq -r .properties.policyDefinitions $f | sed -e 's/%%entlzprefix%%/jblz1/g'`; \
params=`jq -r .properties.parameters $f`; \
az policy set-definition create --name "$name" --description "$description" --display-name "$displayName" --definitions "$definitions" --params "$params" --management-group "jblz1"   ;\
done

# Delay 120
sleep 120

# Deploy Policy Assignments
for f in $(find templates/entlz/es-hubspoke/policies/policies -name assign.*.json); \
do name=`jq -r .name $f`; \
displayName=`jq -r .properties.displayName $f`; \
location="usgovvirginia"; \
policy=`jq -r .properties.policyDefinitionId $f | sed -e 's/%%entlzprefix%%/jblz1/g' | sed -e 's/%%location%%/usgovvirginia/g' | sed -e 's/%%managementsubid%%/07526f72-6689-42be-945f-bb6ad0214b71/g'`; \
params=`jq -r .properties.parameters $f | sed -e 's/%%entlzprefix%%/jblz1/g' | sed -e 's/%%location%%/usgovvirginia/g' | sed -e 's/%%managementsubid%%/07526f72-6689-42be-945f-bb6ad0214b71/g'`; \
scope=`jq -r .properties.scope $f | sed -e 's/%%entlzprefix%%/jblz1/g' | sed -e 's/%%location%%/usgovvirginia/g' | sed -e 's/%%managementsubid%%/07526f72-6689-42be-945f-bb6ad0214b71/g'`; \
sku=`jq -r .sku.tier $f`; \
identity=`jq -r .identity $f`; \
role=`jq -r .identity.role $f`; \
[[ -z $role ]] && role="Contributor"; \
echo "Creating Policy Assignment $name"; \
if [[ $identity = "null" ]]  ;
then
az policy assignment create --name "$name" --display-name "$displayName" --location "$location" --policy "$policy" --params "$params" --scope "$scope"  --sku "$sku";
else
az policy assignment create --name "$name" --display-name "$displayName" --location "$location" --policy "$policy" --params "$params"  --scope "$scope"  --sku "$sku"  --assign-identity --identity-scope "$scope" --role "$role";
fi ; \
done

# Deploy Initiative Assignments
for f in $(find templates/entlz/es-hubspoke/policies/initiatives -name assign.*.json); \
do name=`jq -r .name $f`; \
displayName=`jq -r .properties.displayName $f`; \
location="usgovvirginia"; \
policySetDefinition=`jq -r .properties.policyDefinitionId $f | sed -e 's/%%entlzprefix%%/jblz1/g' | sed -e 's/%%location%%/usgovvirginia/g' | sed -e 's/%%managementsubid%%/07526f72-6689-42be-945f-bb6ad0214b71/g'`; \
params=`jq -r .properties.parameters $f | sed -e 's/%%entlzprefix%%/jblz1/g' | sed -e 's/%%location%%/usgovvirginia/g' | sed -e 's/%%managementsubid%%/07526f72-6689-42be-945f-bb6ad0214b71/g'`; \
scope=`jq -r .properties.scope $f | sed -e 's/%%entlzprefix%%/jblz1/g' | sed -e 's/%%location%%/usgovvirginia/g' | sed -e 's/%%managementsubid%%/07526f72-6689-42be-945f-bb6ad0214b71/g'`; \
sku=`jq -r .sku.tier $f`; \
identity=`jq -r .identity $f`; \
role=`jq -r .identity.role $f`; \
[[ -z $role ]] && role="Contributor"; \
echo "Creating Initiative Assignment $name"; \
if [[ $identity = "null" ]]  ;
then
az policy assignment create --name "$name" --display-name "$displayName" --location "$location" --policy-set-definition "$policySetDefinition" --params "$params" --scope "$scope"  --sku "$sku";
else
az policy assignment create --name "$name" --display-name "$displayName" --location "$location" --policy-set-definition "$policySetDefinition" --params "$params" --scope "$scope"  --sku "$sku"  --assign-identity --identity-scope "$scope" --role "$role";
fi; \
done

# Delay 120
sleep 120
```

## Pipeline 3 - Deploy Platform Subscriptions

## Pipeline 4 - Deploy Platform Management

## Pipeline 5 - Deploy Platform Connectivity

## User Landing Zone Pipelines

## Enterprise Service Pipelines

# List of Modifications from Original templates
## Changes required for MAG
The templates must be modified from their original source to deploy successfully to MAG as described at:
* [Deploy Enterprise Scale Landing Zone from CICD Pipeline in MAG](../README.md)

## Management Group Updates
The management group hierarchy declared in **mgmtGroups.json** has been modified as follows:

        Tenant Root Group
            CAF (Root)
                CAF-Platform
                    CAF-Management
                    CAF-Identity
                    CAF-Connectivity
                CAF-LandingZones
                    CAF-Intranet
                        CAF-Program1
                        CAF-Program2
                        CAF-Program3
                    CAF-Extranet
                CAF-Decomissioned
                CAF-Sandboxes
                    CAF-Sandbox-Management
                    CAF-Sandbox-LandingZones

## Policy Definitions
The following Policy Definitions have been added/modified in **policies.json**:
* **Enforce-Subn-RouteTable** Enforce Route Table on All Subnets. Takes the following parameters:
  
        RouteTableResourceGroup (Default: Locked)
        RouteTableName (Default: RouteTable)

* **Deploy-AzureBackup-on-VM** Deploys if not exist a backup vault in the resourcegroup of  the virtual machine and enabled the backup for the virtual machine with defaultPolicy enabled.

## Landing Zone Policy Assignments
The policy assignments have been added/modified in a new template file called **lz.json**:
* **Deploy-VM-Backup** Deploys if not exist a backup vault in the resourcegroup of  the virtual machine and enabled the backup for the virtual machine with defaultPolicy enabled at **CAF-LandingZone** MG Scope. 

## Intranet Landing Zone Policy Assignments
The policy assignments have been added/modified in a new template file called **intranetlz.json**:
* **Deny-Intranet-Public-PaaS-Endpoints** Public network access should be disabled for PAAS services (Initiative) assigned at **CAF-Intranet** MG Scope.  This policy applies to the following PaaS Services:  
  
        Cosmos
        MariaDB
        MySQL
        PostgreSQL
        KeyVault
        SqlServer
        Storage
        AKS

* **Allowed-Intranet-Resource-Types** Allowed resource types (Policy) assigned at **CAF-Intranet** MG Scope.  The following Services are allowed:
        
        Microsoft.Compute (All)

* **Enforce-Subn-RouteTable** Enforce Route Table on All Subnets assigned at **CAF-Intranet** MG Scope.
