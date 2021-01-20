# Deploy Enterprise Scale Landing Zone from CICD Pipeline in MAG

The Enterprise-Scale architecture is modular by design and allow organizations to start with foundational landing zones that support their application portfolios and add hybrid connectivity with ExpressRoute or VPN when required. Alternatively, organizations can start with an Enterprise-Scale architecture based on the traditional hub and spoke network topology if customers require hybrid connectivity to on-premises locations from the begining.  

## Required Modifications for Microsoft Azure Government (MAG)
The original source for the Enterprise Scale Landing Zones can be found on GitHub at:
* [Hybrid Connectivity with VWAN Hub and Spoke (Contoso)](https://github.com/Azure/Enterprise-Scale/blob/main/docs/reference/contoso/Readme.md)
* [Hybrid Connectivity with VNET Hub-and-Spoke (AdventureWorks)](https://github.com/Azure/Enterprise-Scale/blob/main/docs/reference/adventureworks/README.md)
* [No Hybrid Connectivity (WingTip)](https://github.com/Azure/Enterprise-Scale/blob/main/docs/reference/wingtip/README.md)

The version of source code tested on MAG was pulled on **01/20/2021**.  In order to deploy any of these templates to Microsoft Azure Government (MAG) the following modifications must be made:

### Asc Configuration for AppServices and KeyVaults
The diagnosticsAndSecurity.json template attempts to enable Asc for AppServices and KeyVaults.  While these services are available in MAG, the Asc extensions for them are not.  As a result the following errors are received "The name 'AppServices' is not a valid name. Possible pricing bundle names: VirtualMachines, SqlServers, StorageAccounts, KubernetesService, ContainerRegistry." and "The name 'KeyVaults' is not a valid name. Possible pricing bundle names: VirtualMachines, SqlServers, StorageAccounts, KubernetesService, ContainerRegistry."  The workaround involves removing ASC references to AppServices and KeyVaults in the **diagnosticsAndSecurity.json** template file as described below:
1. Remove the following code block:
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
```
2. Modify the following code block:
```
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
as follows:
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
3. Remove the following code block from the template:
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
```    
4. Modify the following code block:
```
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
as follows:
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
### Disable AKS Policy in Template Parameters File

While AKS is available in MAG the **lz.json** template references Policy Definition ID /providers/Microsoft.Authorization/policyDefinitions/**0a15ec92-a229-4763-bb14-0ea34a568f8d** with name **[Preview]: Azure Policy Add-on for Kubernetes service (AKS) should be installed and enabled on your clusters**.  This Policy definition is not available in MAG.  The AKS policy can be enabled in the parameters file with no changes to any other template files.
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