![](media/openshift.png)
# Installing a Red Hat OpenShift Private Cluster in Azure Government (MAG)
The general instructions for deploying an OpenShift Private Cluster in MAG using scripted solution can be found at https://docs.openshift.com/container-platform/4.6/installing/installing_azure/installing-azure-private.html.  There is also information for deploying the environment using an ARM template at https://docs.openshift.com/container-platform/4.6/installing/installing_azure/installing-azure-user-infra.html.  This repo contains a customized version of the scripted solution with a condensed set of intructions to get up and going quickly.

## Prereqs
1. Deploy a Linux Jump Box on the Azure Private VNET where the cluster will be deployed to allow for support data to be collected during install.  On this server install and setup the Azure CLI from https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux.  Also download the install files including "OpenShift Installer", "Pull Secret" and "Command Line Interface" files from https://cloud.redhat.com/openshift/install/azure/user-provisioned.
2. Review details about the OpenShift Container Platform installation and update processes - https://docs.openshift.com/container-platform/4.6/installing/installing_azure/installing-azure-private.html
3. Create Azure Account and Service Princpal with Required Permissions - https://docs.openshift.com/container-platform/4.6/installing/installing_azure/installing-azure-account.html
4. If you use a firewall, you must configure it to allow the sites that your cluster requires access to.
5. If you do not allow the system to manage identity and access management (IAM), then a cluster administrator can manually create and maintain IAM credentials. Manual mode can also be used in environments where the cloud IAM APIs are not reachable.
6. Generating an SSH private key and adding it to the agent - https://docs.openshift.com/container-platform/4.6/installing/installing_azure/installing-azure-private.html#ssh-agent-using_installing-azure-private
7. Customize the "install-config.yaml" - https://docs.openshift.com/container-platform/4.6/installing/installing_azure/installing-azure-private.html#ssh-agent-using_installing-azure-private

    The primary customizations have to do with specifying Azure Government Cloud and Region, and, for the private cluster deployment, you must also specify the existing VNET and Subnets to use.  These are all contained within the "platform:" element in the yaml.
    ```
    platform:
        azure:
            region: usgovvirginia
            baseDomainResourceGroupName: openshift_cluster 
            networkResourceGroupName: sandbox1-openshift-network 
            virtualNetwork: sandbox1-openshift-vnet 
            controlPlaneSubnet: master 
            computeSubnet: worker 
            outboundType: UserDefinedRouting 
            cloudName: AzureUSGovernmentCloud
    ```
    Detailed configuration parameters can be found at https://docs.openshift.com/container-platform/4.6/installing/installing_azure/installing-azure-private.html#installation-configuration-parameters_installing-azure-private.  

8. Configure Cluster Wide Proxy (if required) - https://docs.openshift.com/container-platform/4.6/installing/installing_azure/installing-azure-private.html#installation-configure-proxy_installing-azure-private

## Solution Deployment
1. Deploy the Cluster - https://docs.openshift.com/container-platform/4.6/installing/installing_azure/installing-azure-private.html#installation-launching-installer_installing-azure-private

Create a new "Install" folder and make a copy of "install-config.yaml".  This file will be removed during the installation process so keeping a copy seperate is important if a subsequent deployment must be done.

```
    # Sample Syntax
    ./openshift-install create cluster --dir=<installation_directory> \ 
    --log-level=info 
```

2. Install the CLI Tools - https://docs.openshift.com/container-platform/4.6/installing/installing_azure/installing-azure-private.html#cli-installing-cli_installing-azure-private

```
    # Sample Syntax
    ./openshift-install create cluster --dir=<installation_directory> \ 
        --log-level=info 
```


## Connecting to Cluster
1. Connect through Console - https://console-openshift-console.apps.test-cluster.magsolutions.us

    Recommend using Chrome to connect to site due to Javascript issue with IE on Server 2019.

2. Connect through CLI Tools

    To access the cluster as the system:admin user when using 'oc', run 'export KUBECONFIG=/home/azureadmin/openshift/install/auth/kubeconfig'

    ```
        oc whoami

        oc login
    ```