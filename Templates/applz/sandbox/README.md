
# Sandbox Management and Landing Zone
This solution deploys a single Sandbox Management Zone and multiple Sandbox User Landing Zones to support development activities in an isolated network environment.  It is recommended this be deployed in an existing CAF Enterprise Scale Architecture in the "Sandboxes" management group.  The Management Zone should be in its own dedicated subscription in a "Sandbox-Management" management group and the User Landing Zones each in their own dedicated subscription all located under a "Sandbox-LandingZones" management group.  The Management Zone solution is deploy once and includes the required connectivity and security components to allow access to User Landing Zones.  After the Management Zone subscription is configured multiple User Landing Zone subscriptions can be configured using the custom Azure Blueprint provided.  The blueprint can be locked on assignment to prevent sandbox users from chaning the default connectivity configuration while allowing them access to deploy all other required resources.  The diagram depicts the Sandbox solution.
![Sandbox Landing Zone](media/sandboxLz.png)

# Instructions
1. **Deploy the Management Zone** - One time only
   
   Create a new subscription for Sandbox Management under the "Sandboxes-Management" Management Group (see CAF Enterprise Scale Architecture).  Create a new Resource Group called "sandbox-management" in the subscription and deploy the included ["sandbox-management.json"](sandbox-management-template\sandbox-management.json) ARM template to it.  Please note when specifying parameters the Key Vault name must be unique across all of Azure.  The Sandbox Management template creates a new User Defined Managed Identity called Sandbox-Deployer and automatically gives it rights to access the KeyVault.  This account must also be given "Contributor" rights to the Sandbox Management subscription.

   
2. **Deploy the Sandbox User Landing Zone**
   
   User Landing Zones are deployed using the included Azure Blueprint (see sandbox-blueprint folder).  The Blueprint deployes the required connectivity components into a new subscription which route back through the management zone hub network where firewall and bastion services are maintained for centralized use.  When assigned the Blueprint can be locked to prevent changes to connectivity components.  Before deploying the first landing zone the Blueprint must be imported.  User the following syntax to import the Blueprint:
   
    ```   
    For Powershell:
    Import-AzBlueprintWithArtifact -Name "sandbox" -ManagementGroupId "EnterCustomMG" -InputPath "path/to/blueprint/directory"

    For AzCLI:
    az blueprint import --name sandbox --input-path "path/to/blueprint/directory" --management-group "EnterCustomMG"
    ```

    Once imported publish the Blueprint so it can be assigend to new scopes.  Create a new subscription for the Sandbox User Landing zone and grant the Sandbox-Deployer managed identity from Sandbox Management template contributor rights at the subscription level.  Assign the Sandbox Blueprint to the new subscription.

