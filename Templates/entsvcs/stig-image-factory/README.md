![](media\disa-stig-logo.jpg)
# DISA STIG Image Factory
This solution is based on the Project-Stig solution documented at https://github.com/shawngib/project-stig.  It is recommended to download the latest version of the solution.  This repo contains instructions for integrating the solution in a MAG Enterprise Scale Landing Zone architecture. 

# Current Architecture
The overall architecture is to use a set of resources deployed via nested ARM templates from this repo. The result is an automated VM image creation via Azure Image Builder and final STIG'd images stored in the resource groups Shared Image Gallery for use in that subscription. Logging is the HTTPS ingestion API for Log Analytics and DSC Audit logs of PowerSTIG and it will not interfere with any agents monitoring for other purposes.

Basic resources used:

* Shared Image Gallery
* Image Definitions
* Image Builder Templates
* GitHub
* Log Analytics Workspace
* Azure Automation (for future use)
* Managed Identity
* Azure Workbook for Sentinel and Log Analytics
* PowerShell during creation and for reporting audits. Note: This is scheduled every 20 minutes and can be modified prior to deploying in the setPowerStig.ps1 script on the second to last line.

![](media\project-stig-arch.jpg)

# Deployment to MAG
