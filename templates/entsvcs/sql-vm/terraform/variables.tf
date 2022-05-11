//Create a azure Resource Group
variable "resourcegroup" {
  description = "Name of the azure ResourceGroup"
  default     = "terraform-demo"
}
variable "location" {
  description = "location for all the resources"
  default     = "usgovvirginia"
}

//The following section identifies existing virtual network and subnet:
variable "virtnetname" {
  description = "name of the virtualNetwork"
  default     = "terraform-demo-vnet"
}

variable "virtnetrg" {
  description = "name of the virtualNetwork"
  default     = "terraform-demo-vnet"
}

variable "subnetname" {
  description = "Name of the SubnetMask"
  default     = "data"
}

// Create public IPs
variable "publicip" {
  description = "Public Ip of the VM"
  default     = "sqlPublicIP"
}

// Create Network Security Group and rule For Sql Server vm
variable "sqlsecgrp" {
  description = "Security Group name of the VM"
  default     = "sql_sec_grp"
}

variable "sqlserver_port1_name" {
  description = "name of the port"
  default = "rdp"
}

variable "sql_port_number1" {
  description = "rdp port"
  default = "3389"
}

variable "sqlserver_port2_name" {
  description = "name of the port2"
  default = "sql"
}

variable "sql_port_number2" {
  description = "sql server port"
  default = "1433"
}

//This creates a virtual NIC named acctNIC connected to the virtual networking resources we have created:
variable "sqlnicnew" {
  description = "sqlvm network interface card"
  default = "sqlnicnew"
}

variable "sqlvmipnew-configuration" {
  description = "name of the sqlvmipnew-configuration"
  default = "sqlvmipnew-configuration"
}

//The following section creates a VM and attaches the virtual NIC to it.

variable "sqlvmname" {
  description = "sqlvmname"
  default = "sqlvminstancenew"
}
variable "vm_size" {
  description = "vm_size"
  default = "Standard_D4s_v3"
}

//Find the VM images in the Azure Marketplace with the Azure CLI tool
variable "i_offer" {
  description = "offer for the vm"
  default = "SQL2016SP1-WS2016"
}
variable "i_publisher" {
  description = "Publisher for the  vm"
  default = "MicrosoftSQLServer"
}

variable "i_sku" {
  description = "sku for the vm"
  default = "SQLDEV"
}
variable "i_version" {
  description = "version for the vm"
  default = "latest"
}

//boot diagnosetic: 
#variable "boot_url" {
#  description = "boot_url"
#  default = "https://xxxxxx.blob.core.usgovcloudapi.net"
#}

//Windows OS disk by default it is of 128 GB
variable "os_disk" {
  description = "os_disk"
  default = "sqlnewOsDisk"
}
// Adding additional disk for persistent storage
variable "add_disk_name" {
  description = "additional_disk"
  default = "sqlvm_disk_1"
}
variable "add_disk_size" {
  description = "disk size in GB"
  default = "128"
}

//Here defined admin uid/pwd and also comupter name
variable "computer_name" {
  description = "name"
  default = "sqlxvm"
}

variable "admin_username" {
  description = "name"
  default = "azureadmin"
}

variable "admin_password" {
  description = "passwd"
  default = "password123!!"
}