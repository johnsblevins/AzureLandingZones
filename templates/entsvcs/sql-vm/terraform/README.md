# Terraform Demo - SQL VM Deployment
This project deploys and Azure Virtual Machine running Server 2016 with SQL Server 2016 Installed using Terraform Infrastructure as Code.  The VM is deployed to and existing Virtual Network and Subnet.

# Prereqs (required when not using Azure Cloud Shell)

1. Download and Install Az Cli
Installers for Windows, Mac and Linux can be found at https://docs.microsoft.com/en-us/cli/azure/install-azure-cli.  

2. Download and install Terraform
Terraform is packaged as a single executable file.  Downloads for Windows, Mac and linux can be found at https://www.terraform.io/downloads.  The file should be copied to the local working directory or placed in a folder that is included in the path environmental variable.

3. Download and Install Git
This project is contained ina Git repo which must be cloned locally to deploy the solution.  Git client tools are opensource and can be downloaded for Windows, Mac and Linux at https://git-scm.com/.

4. Download and Install VS Code and Related terraform Extensions (optional)
VS Code is an IDE that makes developing code, including Terraform, faster and simpler.  Installers for Windows, Mac and Linux can be found at https://code.visualstudio.com/.


# Deployment Steps

1. Clone the repo

```
git clone

# Run setupenv.sh
Recommended to execute script steps manually during first execution and customize as needed for automated deployment.