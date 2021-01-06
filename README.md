![](media/azure-gov.png)
# Azure Landing Zones for MAG 
Azure landing zones are the output of a multisubscription Azure environment that accounts for scale, security, governance, networking, and identity. Azure landing zones enable application migrations and greenfield development at enterprise scale in Azure. These zones consider all platform resources that are required to support the customer's application portfolio and don't differentiate between infrastructure as a service or platform as a service. See https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/.  It is recommended that you take the training path at https://docs.microsoft.com/en-us/learn/paths/enterprise-scale-architecture/ before deploying your first landing zone.  For more information on the Cloud Adoption Framework (CAF) see https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/.  For CAF learning see https://docs.microsoft.com/en-us/learn/modules/microsoft-cloud-adoption-framework-for-azure/. 

![](media/entlz-small.png)


Landing Zones are deployed using Blueprints or with custom Azure Resource Manager (ARM) or Terraform Templates.  See https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/enterprise-scale/.  These are CAF aligned with additional governance implemented at the Management Group Level and meant for enterprise deployments in advanced cloud hosting scenarios.  The orginal source for the ARM based solutions can be found on GitHub at https://github.com/Azure/Enterprise-Scale and the Terraform based solutions at https://github.com/azure/caf-terraform-landingzones.  Each Azure landing zone implementation option provides a deployment approach and defined design principles. Before choosing an implementation option, use the article at https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/design-areas to gain an understanding of the design areas for each implementation. 

The landing zone solutions contained in this repository are based on the CAF aligned architectures referenced above and have been refactored to support Microsoft Azure Government (MAG) environments.  The **Enterprise Scale Landing Zone** should be deployed first to create the overall cloud management structure and governance for the hosting environment.  This includes the management group hierarchy, policies, connectivity, and management components needed to centrally administer the entire environment.  Additional **Enterprise Services** can be deployed to extended the environment based on requirements.  These may include additional identity integration, management and security solutions required by the enterprise.  **App Landing Zones** are then deployed to onboard new application owner subscriptions into the hosting environment.  App landing zones setup and enforce the required policy, compliance and connectivity components within the subscription.

# Solutions

## Step 1 - Deploying Enterprise-scale Landing Zone
Step 1 is to e
Select scenario:
* [CAF Enterprise-scale Landing Zone on MAG (ARM-hybrid connectivity with hub and spoke)](Templates/entscalelz/es-hubspoke-template)

## Step 2 - Deploy Additional Enterprise Services
Select scenario:
* [Active Directory Zonal Deployment](Templates/entsvcs/active-directory-new-domain-ha-2-dc-zones/)

## Step 3 - Deploy App Landing Zones
Select scenario:
* [Deploy Sandbox Landing Zone](Templates/applz/sandbox)
* [Deploy FedRAMP Moderate App Landing Zone](Templates/applz/fedrampmod)

# Additional Resources
## Microsoft Well-Architected Framework
The Azure Well-Architected Framework is a set of guiding tenets that can be used to improve the quality of a workload. The framework consists of five pillars of architecture excellence: Cost Optimization, Operational Excellence, Performance Efficiency, Reliability, and Security.  See https://docs.microsoft.com/en-us/azure/architecture/framework/.



 

