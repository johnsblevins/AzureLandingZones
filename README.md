# Azure Landing Zones
What is an Azure **Landing Zone (LZ)**? See https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/.

Considerations for Design of LZ.  See https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/design-areas.

LZ Implementation Options.  See https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/implementation-options.

## Training
Create an enterprise-scale architecture in Azure.  See https://docs.microsoft.com/en-us/learn/paths/enterprise-scale-architecture/.

# Deployment
## Step 1 - Deploying Enterprise-scale Landing Zone

**Enterprise LZs** are deployed using Blueprints or with custom Azure Resource Manager (ARM) or Terraform Templates.  See https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/enterprise-scale/.  These are CAF aligned with additional governance implemented at the Management Group Level and meant for enterprise deployments in advanced cloud hosting scenarios.  The orginal source for the ARM based solutions can be found on GitHub at https://github.com/Azure/Enterprise-Scale and the Terraform based solutions at https://github.com/azure/caf-terraform-landingzones.  The versions contained in this repository include a cloned copy of the original templates, as well as an added set of CICD script and template files for use by DevOps teams to customize the solution and make the deployment repeatable in their environment.  The following Enterprise Landings Zone templates exist:
* [CAF Enterprise-scale Landing Zone on MAG (ARM-Foundation)](Templates/ARM/es-foundation)
* [CAF Enterprise-scale Landing Zone on MAG (ARM-hybrid connectivity with Virtual WAN)](Templates/ARM/es-vwan)
* [CAF Enterprise-scale Landing Zone on MAG (ARM-hybrid connectivity with hub and spoke)](Templates/ARM/es-hubspoke)
* [CAF Enterprise-scale Landing Zone on MAG (Terraform Modules)](Templates/Terraform)
* [Partner Landing Zones](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/partner-landing-zone)

**Basic LZs** can be deployed with Built-In Azure Blueprints in the Azure Portal.  These are Cloud Adoption Framework (CAF) aligned but more limited, subscription level LZs, with little governance and meant for smaller deployments or for teams just learning about cloud.  The following Basic LZ Blueprints exist: 
* CAF Foundation, https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/foundation-blueprint - Constists of base set of governance and infrastructure components.
* CAF Migration, https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/migrate-landing-zone - Enables Azure Migrate infrastructure to migrate on-prem VMs to cloud; Recommended to deploy CAF Foundation first.
  
**Zero Trust Blueprint**
Another option is the **Zero Trust Landing Zone Blueprint** available at https://github.com/Azure/ato-toolkit.

## Step 2 - Deploy Additional Enterprise Services

**Active Directory** can be deployed using Templates.
* [ADDS Zonal Deployment](Templates\entsvcs\adds\active-directory-new-domain-ha-2-dc-zones)

## Step 3 - Deploy App/Mission Owner Landing Zones

* [Deploy Additional Enterprise-scale Landing Zone subscriptions (ARM)](Templates/ARM/lzs) - Assumes Base Landing Zone with Governance Already Deployed

# Compliance Blueprints
Once the CAF aligned landing zone is deployed with base governance you can layer on top additional Built-in Azure Blueprints to enforce common Federal compliance frameworks.  Many of these Blueprint implement Azure Policy and Governance around the landing zone versus deploying actual infrastructure:
* FedRAMP Moderate - https://docs.microsoft.com/en-us/azure/governance/blueprints/samples/fedramp-m/
* FedRAMP High - https://docs.microsoft.com/en-us/azure/governance/blueprints/samples/fedramp-h/
* DoD Impact Level 4 - https://docs.microsoft.com/en-us/azure/governance/blueprints/samples/dod-impact-level-4/
* DoD Impact Level 5 - https://docs.microsoft.com/en-us/azure/governance/blueprints/samples/dod-impact-level-5/






 

