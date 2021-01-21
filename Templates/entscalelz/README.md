# Deploy Enterprise Scale Landing Zone from CICD Pipeline in MAG

The Enterprise-Scale architecture is modular by design and allow organizations to start with foundational landing zones that support their application portfolios and add hybrid connectivity with ExpressRoute or VPN when required. Alternatively, organizations can start with an Enterprise-Scale architecture based on the traditional hub and spoke network topology if customers require hybrid connectivity to on-premises locations from the begining.  

## CICD
The original source for the Enterprise Scale Landing Zones can be found on GitHub at:
* [Hybrid Connectivity with VWAN Hub and Spoke (Contoso)](https://github.com/Azure/Enterprise-Scale/blob/main/docs/reference/contoso/Readme.md)
* [Hybrid Connectivity with VNET Hub-and-Spoke (AdventureWorks)](https://github.com/Azure/Enterprise-Scale/blob/main/docs/reference/adventureworks/README.md)
* [No Hybrid Connectivity (WingTip)](https://github.com/Azure/Enterprise-Scale/blob/main/docs/reference/wingtip/README.md)

In order to deploy these templates through a CICD pipeline internal to the organization:
1. Clone the source repo from GitHub to a temp location
2. Create a new local repo for the solution
3. Copy the **armTemplates** directory from source repo to solution repo
4. Modify the Templates as required (see below section for modifications required for MAG)
5. Add a customized **Parameters** file in the solution repo and check in to source control (Click here for a sample)
6. Configure CICD Tool and Pipline to Deploy Template to Azure (See below sections for GitHub, GitLabs and ADO for connection instructions)

### CICD Tools

#### GitHub
Deploy Azure Resource Manager (ARM) Template - https://github.com/marketplace/actions/deploy-azure-resource-manager-arm-template

#### GitLabs
1. Create a Connection
2. YAML Pipeline Sample to Deploy ARM Template
   
#### Azure DevOps
1. Create a Connection
2. YAML Pipeline Sample to Deploy ARM Template
   
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
The **lz.json** template references Policy Definition ID /providers/Microsoft.Authorization/policyDefinitions/**98d0b9f8-fd90-49c9-88e2-d3baf3b0dd86** with name **[Preview]: Configure backup on VMs without a given tag to a new recovery services vault with a default policy**.  This Policy definition is not available in MAG.
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

### Asc Configuration for AppServices and KeyVaults
The **policies.json** template attempts to enable Asc for AppServices and KeyVaults.  While these services are available in MAG, the Asc extensions for them are not.  As a result the following errors are received "The name 'AppServices' is not a valid name. Possible pricing bundle names: VirtualMachines, SqlServers, StorageAccounts, KubernetesService, ContainerRegistry." and "The name 'KeyVaults' is not a valid name. Possible pricing bundle names: VirtualMachines, SqlServers, StorageAccounts, KubernetesService, ContainerRegistry."  The workaround involves removing ASC references to AppServices and KeyVaults in the **policies.json** template file as described below:
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

2. Replace the following code block for SqlServers ASC Reference:
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