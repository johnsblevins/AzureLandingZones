provider "azurerm" {
    subscription_id = "f86eed1f-a251-4b29-a8b3-98089b46ce6c"
    client_id = "619c97f3-dea2-4c36-9cee-541a2b3520ab"
    client_secret = "ZTlDWmM1l2N90-eq6_wREzF4_icA4D-Y0S"
    tenant_id = "6775f0cc-3aaf-4563-8857-e54a12ebb874"
    environment = "usgovernment"
    features {}
}

//Create an azure Resource Group
resource "azurerm_resource_group" "terraform_demorg" {
  name     = "${var.resourcegroup}"
  location = "${var.location}"
}


#refer to a subnet
data "azurerm_subnet" "terraform_demosnet" {
  name                 = "${var.subnetname}"
  virtual_network_name = "${var.virtnetname}"
  resource_group_name  = "${var.virtnetrg}"
}

// Create public IPs
resource "azurerm_public_ip" "terraform_demoip" {
    name                         = "${var.publicip}"
    location                     = "${azurerm_resource_group.terraform_demorg.location}"
    resource_group_name          = "${azurerm_resource_group.terraform_demorg.name}"
    allocation_method            = "Dynamic"

    tags = {
        environment = "stage"
    }
}

// Create Network Security Group and rule For Sql Server vm
resource "azurerm_network_security_group" "terraform_demosecgrp" {
    name                = "${var.sqlsecgrp}"
    location            = "${azurerm_resource_group.terraform_demorg.location}"
    resource_group_name = "${azurerm_resource_group.terraform_demorg.name}"
    
    security_rule {
        name                       = "${var.sqlserver_port1_name}"
        priority                   = "1001"
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "${var.sql_port_number1}"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "${var.sqlserver_port2_name}"
        priority                   = "1002"
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "${var.sql_port_number2}"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}

//Now connect the VM to the  virtual network, public IP address, and network security group.

//This creates a virtual NIC and connects it to the virtual networking resources you have created:

resource "azurerm_network_interface" "terraform_demonic" {
    name = "${var.sqlnicnew}"
    location = "${azurerm_resource_group.terraform_demorg.location}"
    resource_group_name = "${azurerm_resource_group.terraform_demorg.name}"



    ip_configuration {
        name = "${var.sqlvmipnew-configuration}"
        subnet_id = "${data.azurerm_subnet.terraform_demosnet.id}"
        private_ip_address_allocation = "dynamic"
      public_ip_address_id = "${azurerm_public_ip.terraform_demoip.id}"
    }
}

resource "azurerm_network_interface_security_group_association" "nic_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.terraform_demonic.id
  network_security_group_id = azurerm_network_security_group.terraform_demosecgrp.id
}

//The following section creates a VM and attaches the virtual NIC to it.
resource "azurerm_virtual_machine" "terraform_demovm" {
    name = "${var.sqlvmname}"
    location = "${azurerm_resource_group.terraform_demorg.location}"
    resource_group_name = "${azurerm_resource_group.terraform_demorg.name}"
    network_interface_ids = ["${azurerm_network_interface.terraform_demonic.id}"]
    vm_size = "${var.vm_size}"

//https://docs.microsoft.com/en-us/azure/virtual-machines/linux/cli-ps-findimage
//Search the VM images in the Azure Marketplace using Azure CLI tool

//az vm image list --location westeurope  --publisher MicrosoftSQLServer  --all --output table

    storage_image_reference {
        offer     = "${var.i_offer}" 
        publisher = "${var.i_publisher}"
        sku       = "${var.i_sku}" 
        version   = "${var.i_version}"
        }

//boot diagnosetic: here you can provide  the url of the blob for the boot logs storage
    #boot_diagnostics {
    #    enabled     = false
        #storage_uri = "${var.boot_url}"
        #}

//Windows OS disk by default it is of 128 GB
    storage_os_disk {
        name              = "${var.os_disk}"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
            }

// Adding additional disk for persistent storage (need to be mounted to the VM using diskmanagement )
    storage_data_disk {
        name = "${var.add_disk_name}"
        managed_disk_type = "Standard_LRS"
        create_option = "Empty"
        lun = 0
        disk_size_gb = "${var.add_disk_size}"
        }

//Assign the admin uid/pwd and also comupter name
    os_profile {
        computer_name  = "${var.computer_name}"
        admin_username = "${var.admin_username}"
        admin_password = "${var.admin_password}"
    }

//Here defined autoupdate config and also vm agent config
    os_profile_windows_config {  
    //enable_automatic_upgrades = true  
    provision_vm_agent         = true  
  }  
}

//extension configuration section
resource "azurerm_virtual_machine_extension" "terraform_demoextension" {
  name                 = "SqlIaasExtension"
  publisher            = "Microsoft.SqlServer.Management"
  type                 = "SqlIaaSAgent"
  type_handler_version = "1.2"
  virtual_machine_id = azurerm_virtual_machine.terraform_demovm.id
  settings = <<SETTINGS
  {
    "AutoTelemetrySettings": {
      "Region": "West Europe"
    },
    "AutoPatchingSettings": {
      "PatchCategory": "WindowsMandatoryUpdates",
      "Enable": true,
      "DayOfWeek": "Sunday",
      "MaintenanceWindowStartingHour": "2",
      "MaintenanceWindowDuration": "60"
    },
    "KeyVaultCredentialSettings": {
      "Enable": false,
      "CredentialName": ""
    },
    "ServerConfigurationsManagementSettings": {
      "SQLConnectivityUpdateSettings": {
          "ConnectivityType": "Public",
          "Port": "1433"
      },
      "SQLWorkloadTypeUpdateSettings": {
          "SQLWorkloadType": "GENERAL"
      },
      "AdditionalFeaturesServerConfigurations": {
          "IsRServicesEnabled": "true"
      } ,
       "protectedSettings": {
             
           }
           }}
SETTINGS
  tags = {
    terraform = "true"
    Service = "SQL"
  }

}