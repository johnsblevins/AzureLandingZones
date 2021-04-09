# Deploy Enterprise Scale Landing Zone from CICD Pipeline in MAG

If is recommended to deploy the CAF Aligned Enterprise Scale Landing Zone templates to a Microsoft Azure Government (MAG) environment using a CICD build and release pipeline.  The templates must be modified from their original source to deploy successfully to MAG.  This article describes how to deploy the templates from a customer managed CICD pipeline as well as the updates needed to the templates to deploy them to MAG.

## Deploying Enterprise Scale Landing Zones using CICD Pipeline
The original source for the Enterprise Scale Landing Zones can be found on GitHub at:
* [Hybrid Connectivity with VWAN Hub and Spoke (Contoso)](https://github.com/Azure/Enterprise-Scale/blob/main/docs/reference/contoso/Readme.md)
* [Hybrid Connectivity with VNET Hub-and-Spoke (AdventureWorks)](https://github.com/Azure/Enterprise-Scale/blob/main/docs/reference/adventureworks/README.md)
* [No Hybrid Connectivity (WingTip)](https://github.com/Azure/Enterprise-Scale/blob/main/docs/reference/wingtip/README.md)

These templates each consist of a master ARM (json) template file that contain URI references to publicly accessible linked templates from the same GitHub repository.  In order to customize the linked templates, which is required to deploy the solution to Microsoft Azure Government, the source repos must be cloned to a new publicly accessible repository where the ARM deployment service which runs in Azure can reach the linked templates by public URI paths.  ARM cannot connect to a GitHub, Azure DevOps or GitLab repository which requires authentication.  This works well when the source GIT repos can be kept publicly accessible however when the repos must be made private an alternative solution must be employed.  

### Private Repo Option 1 - Sequence Artifacts in CICD Pipeline
The following shows the deployment steps sequenced by resource deployments from the master ARM template.  

    1a. Management Group Deployment - auxiliary\mgmtGroups.json - Tenant Level
    2a. Policy Deployment (Depends on 1a) - auxiliary\policies.json - CAF Root MG Level
    2b. Move Management Sub (Depends on 1a)
    2c. Move Identity Sub (Depends on 1a)
    2d. Move Online Subs (Depends on 1a)
    2e. Move Corp Subs (Depends on 1a)
    3a. Delay 20 (Depends on 2a)   
    4a. Monitoring Deployment (Depends on 2a and 3a) - auxiliary\logAnalytics.json - Management MG Level
    4b. Identity Deployment (Depends on 2a and 3a) - auxiliary\identity.json - Identity MG Level
    4c. Landing Zone Deployment (Depends on 2a and 3a) - lz.json - Landing Zones MG Level
    4d. Move Connectivity Sub (Depends on 3a)
    5a. Monitoring Solutions Deployment (Depends on 4a) - auxiliary\logAnalyticsSolutions.json - Management Sub Level
    5b. Diagnostics and Security (Depends on 3a and 4a) - auxiliary\diagnosticsAndSecurity.json - CAF Root MG Level
    6a. Connectivity Deployment (Depends on 3a and 5b) - auxiliary\hubspoke-connectivity.json - Connectivity MG Level

A CICD pipeline can be created which mimics the deployment sequence above.  See below for some samples.

* [Sample GitLab Pipeline for Enterprise Scale Hub and Spoke Landing Zone](es-hubspoke-template/cicd/gitlab-sample.yml)
* [Sample GitHub Pipeline for Enterprise Scale Hub and Spoke Landing Zone](es-hubspoke-template/cicd/github-sample.yml)


### Private Repo Option 2 - Utilize Storage Account with SAS Key for Artifacts
As an alternative to sequencing the deployments using a pipeline, the master arm template can be refactored to include storage account URI and SAS token parameters.  A CICD pipeline can then be created, which creates an Azure storage account with SAS token, copies the source repo to the storage account and executes the master template passing in the storage account URI and SAS token.  The ARM deployment service will use the SAS URI to access the storage account over the Azure backbone network allowing the deployment to complete in the same fashion as having the files in publicly accessible GIT repository.  As a final step the pipeline should remove the storage account.

## Required Modifications for Microsoft Azure Government (MAG)

The version of source code tested on MAG was pulled on **01/20/2021**.  In order to deploy any of these templates to Microsoft Azure Government (MAG) the following modifications must be made:

### US Government 
In the variables section of the **es-hubspoke.json** template file Azure Government is not referenced properly which breaks the policy assignment.  To correct this change the following code:
```
    "variables": {
        "azPolicyEnvMapping": {
            "https://management.azure.com/": "auxiliary/policies.json",
            "https://management.chinacloudapi.cn": "auxiliary/mkPolicies.json",
            "https://management.azgov.com": "auxiliary/"
```
to:
```
    "variables": {
        "azPolicyEnvMapping": {
            "https://management.azure.com/": "auxiliary/policies.json",
            "https://management.chinacloudapi.cn": "auxiliary/mkPolicies.json",
            "https://management.usgovcloudapi.net": "auxiliary/policies.json"
```

### Enable VM Backup Policy Definition Unavailable
The **lz.json** and **identity.json** templates reference Policy Definition ID /providers/Microsoft.Authorization/policyDefinitions/**98d0b9f8-fd90-49c9-88e2-d3baf3b0dd86** with name **[Preview]: Configure backup on VMs without a given tag to a new recovery services vault with a default policy**.  This Policy definition is not available in MAG.
1. Disable VM Backup
```
    "enableVmBackup": {
      "value": "No"
    },
```
as well as:
```
    "enableVmBackupForIdentity": {
      "value": "No"
    },
```
2. Alternatively you can Update the Policy Definition to support enforcing VM Backups
The default Ent Scale templates can be updated to include a custom policy definition to enforce Vm Backup.  See the following [article](policies/enforce-vm-backup/README.md) for instructions on how to implement the VM Backup solution.

### Disable AKS Policy in Template Parameters File
While AKS is available in MAG the **lz.json** template references Policy Definition ID /providers/Microsoft.Authorization/policyDefinitions/**a8eff44f-8c92-45c3-a3fb-9880802d67a7** with name **Deploy Azure Policy Add-on to Azure Kubernetes Service clusters**.  This Policy definition is not available in MAG.  The AKS policy can be enabled in the parameters file with no changes to any other template files.
1. Disable Aks Policy
```
    "enableAksPolicy": {
      "value": "No"
    }
```

### Disable Arc Policy in Template Parameters File
While Arc is available in MAG the **lz.json** template references Policy Definition ID /providers/Microsoft.Authorization/policyDefinitions/**69af7d4a-7b18-4044-93a9-2651498ef203** with name **[Preview]: Deploy Log Analytics agent to Windows Azure Arc machines and /providers/Microsoft.Authorization/policyDefinitions/9d2b61b4-1d14-4a63-be30-d4498e7ad2cf with name [Preview]: Deploy Log Analytics agent to Linux Azure Arc machines**.  These Policy definitions are not available in MAG.  The Arc policies can be disabled in the parameters file with no changes to any other template files.
1. Disable Arc Monitoring
```
    "enableArcMonitoring": {
      "value": "No"
    }
```

### Asc Configuration for AppServices, KeyVaults, DNS and ARM
The **policies.json** template attempts to enable Asc for AppServices, KeyVaults, DNS and ARM.  While these services are available in MAG, the Asc extensions for them are not.  As a result the following errors are received "The name 'AppServices' is not a valid name. Possible pricing bundle names: VirtualMachines, SqlServers, StorageAccounts, KubernetesService, ContainerRegistry." and "The name 'KeyVaults' is not a valid name. Possible pricing bundle names: VirtualMachines, SqlServers, StorageAccounts, KubernetesService, ContainerRegistry."  The workaround involves removing ASC references to AppServices and KeyVaults in the **policies.json** template file as described below:
1. Replace the following code block for AppServices ASC Reference:
```
  {
    "type": "Microsoft.Security/pricings",
    "apiVersion": "2018-06-01",
    "name": "AppServices",
    "dependsOn": [
      "[[concat('Microsoft.Security/pricings/StorageAccounts')]"
    ],
    "properties": {
      "pricingTier": "[[parameters('pricingTierAppServices')]"
    }
  },
  {
    "type": "Microsoft.Security/pricings",
    "apiVersion": "2018-06-01",
    "name": "SqlServers",
    "dependsOn": [
      "[[concat('Microsoft.Security/pricings/AppServices')]"
    ],
    "properties": {
      "pricingTier": "[[parameters('pricingTierSqlServers')]"
    }
  },
```
with:
```
  {
    "type": "Microsoft.Security/pricings",
    "apiVersion": "2018-06-01",
    "name": "SqlServers",
    "dependsOn": [
      "[[concat('Microsoft.Security/pricings/StorageAccounts')]"
    ],
    "properties": {
      "pricingTier": "[[parameters('pricingTierSqlServers')]"
    }
  },
```

2. Replace the following code block for Key Vault ASC Reference:
```
{
  "type": "Microsoft.Security/pricings",
  "apiVersion": "2018-06-01",
  "name": "KeyVaults",
  "dependsOn": [
    "[[concat('Microsoft.Security/pricings/SqlServers')]"
  ],
  "properties": {
    "pricingTier": "[[parameters('pricingTierKeyVaults')]"
  }
},
{
  "type": "Microsoft.Security/pricings",
  "apiVersion": "2018-06-01",
  "name": "KubernetesService",
  "dependsOn": [
    "[[concat('Microsoft.Security/pricings/KeyVaults')]"
  ],
  "properties": {
    "pricingTier": "[[parameters('pricingTierKubernetesService')]"
  }
},
```
with:
```
{
  "type": "Microsoft.Security/pricings",
  "apiVersion": "2018-06-01",
  "name": "KubernetesService",
  "dependsOn": [
    "[[concat('Microsoft.Security/pricings/SqlServers')]"
  ],
  "properties": {
    "pricingTier": "[[parameters('pricingTierKubernetesService')]"
  }
},
```

3. Replace the following code block for DNS ASC Reference:
```
{
  "type": "Microsoft.Security/pricings",
  "apiVersion": "2018-06-01",
  "name": "Dns",
  "dependsOn": [
    "[[concat('Microsoft.Security/pricings/ContainerRegistry')]"
  ],
  "properties": {
    "pricingTier": "[[parameters('pricingTierDns')]"
  }
},
{
  "type": "Microsoft.Security/pricings",
  "apiVersion": "2018-06-01",
  "name": "Arm",
  "dependsOn": [
    "[[concat('Microsoft.Security/pricings/Dns')]"
  ],
  "properties": {
    "pricingTier": "[[parameters('pricingTierArm')]"
  }
}
```
with:
```
{
  "type": "Microsoft.Security/pricings",
  "apiVersion": "2018-06-01",
  "name": "Arm",
  "dependsOn": [
    "[[concat('Microsoft.Security/pricings/ContainerRegistry')]"
  ],
  "properties": {
    "pricingTier": "[[parameters('pricingTierArm')]"
  }
}
```

4. Remove the following code block for ARM ASC Reference:

```
  ,
  {
  "type": "Microsoft.Security/pricings",
  "apiVersion": "2018-06-01",
  "name": "Arm",
  "dependsOn": [
  "[[concat('Microsoft.Security/pricings/ContainerRegistry')]"
  ],
  "properties": {
  "pricingTier": "[[parameters('pricingTierArm')]"
  }
  }
```

5. Remove the following unused policy file.
  
```
templates\entscalelz\es-template\auxiliary\mkPolicies.json
```

6. Change references to 'northerneurope' in **policies.json**.  
The following Policy Definitions in **policies.json** are scoped to the subscription level and require a location for deployment metadata (not resources) to be stored:
```
Deploy-Budget
Deploy-Diagnostics-ActivityLog
Deploy-VNET-HubSpoke
Deploy-ASC-Standard
Deploy-FirewallPolicy
Deploy-Log-Analytics
Deploy-DDoSProtection
Deploy-HUB
Deploy-vNet
Deploy-vWAN
Deploy-vHUB
``` 

The references to 'northerneurope' should be replaced by 'usgovvirginia'.  Replace all instances of:
```
"location": "northerneurope",
```
with:
```
"location": "usgovvirginia",
```

7. Remove default value for IPAM parameter with 'westeurope' reference
   
Remove the following block from **policies.json**
```
"defaultValue": [
                              {
                                "name": "bu1-weu-msx3-vNet1",
                                "location": "westeurope",
                                "virtualNetworks": {
                                  "properties": {
                                    "addressSpace": {
                                      "addressPrefixes": [
                                        "10.51.217.0/24"
                                      ]
                                    }
                                  }
                                },
                                "networkSecurityGroups": {
                                  "properties": {
                                    "securityRules": []
                                  }
                                },
                                "routeTables": {
                                  "properties": {
                                    "routes": []
                                  }
                                },
                                "hubVirtualNetworkConnection": {
                                  "vWanVhubResourceId": "/subscriptions/99c2838f-a548-4884-a6e2-38c1f8fb4c0b/resourceGroups/contoso-global-vwan/providers/Microsoft.Network/virtualHubs/contoso-vhub-weu",
                                  "properties": {
                                    "allowHubToRemoteVnetTransit": true,
                                    "allowRemoteVnetToUseHubVnetGateways": false,
                                    "enableInternetSecurity": true
                                  }
                                }
                              }
                            ],
```

8. Remove reference to China Cloud and mkPolicies.json in **es-hubspoke.json**, **es-foundation.json** and **es-vwan.json** Master templates

Remove the following line:
```
"https://management.chinacloudapi.cn": "auxiliary/mkPolicies.json",
```