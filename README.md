![](media/azure-gov.png)
# Azure Landing Zones for MAG 
Azure Landing Zones are the output of a multi-subscription Azure environment that account for scale, security, governance, networking, and identity. Azure landing zones enable application migrations and greenfield development at enterprise scale in Azure. These zones consider all platform resources that are required to support the customer's application portfolio and don't differentiate between infrastructure as a service or platform as a service.  It is recommended to begin with the Cloud Adoption Framework (CAF) aligned Landing Zone reference architectures to ensure a comprehensive and repeatable approach with guidance and templates.
* [CAF Aligned Enterprise Scale Landing Zones](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/)
* [Training Path for Enterprise Scale Architectures](https://docs.microsoft.com/en-us/learn/paths/enterprise-scale-architecture/)
* [Cloud Adoption Framework (CAF) Information](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/)
* [Training Path for CAF](https://docs.microsoft.com/en-us/learn/modules/microsoft-cloud-adoption-framework-for-azure/) 
* [Enterprise Scale ARM Deployment Artifacts on GitHub](https://github.com/Azure/Enterprise-Scale)
* [Enterprise Scale Terraform Deployment Artifacts on GitHub](https://github.com/azure/caf-terraform-landingzones)

The landing zone solutions contained in this repository are based on the CAF aligned architectures referenced above and have been refactored to support Microsoft Azure Government (MAG) environments.  The **Enterprise Scale Landing Zone** should be deployed first to create the overall cloud management structure and governance for the hosting environment.  This includes the management group hierarchy, policies, connectivity, and management components needed to centrally administer the entire environment.  Landing Zones are deployed using Blueprints or with custom Azure Resource Manager (ARM) or Terraform Templates.  It is recommended the templates included  be used as a starting point for the organization to then adjust based on requirements.  The artifacts can be merged into source control and deployment through a CICD pipeline using Infrastructure-as-Code. The following diagram depicts a high level enterprise scale landing zone you can deploy with the solution:

![](media/entlz-small.png)

Once the Enterprise Scale Landing Zone is deployed the organization can onboard Application development teams into the environt using **Application Landing Zone** templates.  App landing zones setup and enforce the required policy, compliance and connectivity components within the app owner's subscription and allow them to rapidly begin development activities in a secure fashion.  The following diagram depicts a Sandbox Landing Zone solution deployed with the Enterprise Scale framework:
![](media/applz-sandbox.png)


In addtion to Enterprise Scale and Application Landing Zones this repository also contains solutions for additional **Enterprise Services** which often are needed to support various hosting requirements.  These may include additional identity integration, management and security solutions required by the enterprise. 




# Getting Started

## Step 1 - Deploying Enterprise-scale Landing Zone
Select a scenario:
* [CAF Enterprise-scale Landing Zone on MAG (ARM-hybrid connectivity with hub and spoke)](Templates/entscalelz/es-hubspoke-template)

## Step 2 - Deploy App Landing Zones
Select a scenario:
* [Deploy Sandbox Landing Zone](Templates/applz/sandbox)
* [Deploy FedRAMP Moderate App Landing Zone](Templates/applz/fedrampmod)

## Step 3 - Deploy Additional Enterprise Services
Select a scenario:
* [Active Directory Zonal Deployment](Templates/entsvcs/active-directory-new-domain-ha-2-dc-zones/)

# Additional Resources
## Microsoft Well-Architected Framework
The Azure Well-Architected Framework is a set of guiding tenets that can be used to improve the quality of a workload. The framework consists of five pillars of architecture excellence: Cost Optimization, Operational Excellence, Performance Efficiency, Reliability, and Security.  See https://docs.microsoft.com/en-us/azure/architecture/framework/.



 

