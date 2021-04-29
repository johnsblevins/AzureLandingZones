variable "addsvm1name" {
  type = string
  default = "addsvm1"
}
variable "addsvm1ip" {
  type = string
  default = "10.0.4.4"
}
variable "addsvm2name" {
  type = string
  default = "addsvm2"
}
variable "addsvm2ip" {
  type = string
  default = "10.0.4.5"
}
variable "adfsvm1name" {
  type = string
  default = "adfsvm1"
}
variable "adfsvm1ip" {
  type = string
  default = "10.0.4.6"
}
variable "adfsvm2name" {
  type = string
  default = "adfsvm2"
}
variable "adfsvm2ip" {
  type = string
  default = "10.0.4.7"
}
variable "aadcvm1name" {
  type = string
  default = "aadcvm1"
}
variable "aadcvm1ip" {
  type = string
  default = "10.0.4.8"
}
variable "aadcvm2name" {
  type = string
  default = "aadcvm2"
}
variable "aadcvm2ip" {
  type = string
  default = "10.0.4.9"
}
variable "linvm1name" {
  type = string
  default = "linvm1"
}
variable "linvm1ip" {
  type = string
  default = "10.0.4.10"
}
variable "linvm2name" {
  type = string
  default = "aadcvm2"
}
variable "linvm2ip" {
  type = string
  default = "10.0.4.11"
}
variable "location" {
  type = string
  default = "usgovvirginia"
}
variable "environment" {
  type = string
  default = "usgovernment"
}
variable "subscriptionId" {
  type = string
  default = "787e871a-84ba-43be-86bf-86bd1e408a4a"
}
variable "vmsize" {
  type = string
  default = "Standard_B2s"
}
variable "adminusername"{
  type = string
  default = "azuradmin"
}
variable "windowsadminpassword"{
  type = string
  default = "password123!!"
}
variable "linuxpublickey"{
  type = string
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAlVE3LvMk1uRzf1rI9BNIb90aQ4xF6yfin52FsJ6Ezhomi0VZkQo5tx7LT8o7xdInCJ+0aErK4niPFCRVMIO8grQbnB30TGPQf/Cz7CbzQkE5STZ7b/gE4YE9Rl7gwjb+/DqYKD/2jg3jJM6cBcw80bN06O9JxTqM1GLbqxmF4XVOh9Y/2zJ6yskHy60lYDgsAvydUARsQf9KmTE04jO8sQqya+oPU6basKqOjzATIYaHJnaxoMER6oN3CrYJo2h1UxNSUR7alMKHqqFeYbmYZ/7AQzPrsnqfrOoWcJum6EuhCrluiET4HfaHCbXd8eekX2PDmpRAFPnJtLAgGjAA0Q== rsa-key-20210429"
}
variable "subnetname"{
  type = string
  default = "management"
}
variable "vnetname"{
  type = string
  default = "elz1-identity-vnet-usgovvirginia"
} 
variable "vnetrg" {
  type = string
  default = "elz1-identity-connectivity-usgovvirginia"
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  environment = var.environment
  subscription_id = var.subscriptionId
  features {}
}

data "azurerm_client_config" "current" {}

locals {
  tenantid = data.azurerm_client_config.current.tenant_id
}

resource "azurerm_resource_group" "diskencryptionrg" {
  name = "identity-diskencryption-${var.location}"
  location = var.location
}

resource "azurerm_resource_group" "addsrg" {
  name = "identity-adds-${var.location}"
  location = var.location
}

resource "azurerm_resource_group" "adfsrg" {
  name= "identity-adfs-${var.location}"
  location= var.location
}

resource "azurerm_resource_group" "aadcrg" {
  name= "identity-aadc-${var.location}"
  location= var.location
}

resource "azurerm_resource_group" "linrg" {
  name= "lin-${var.location}"
  location= var.location
}

module "diskencryption" {
  source = "./modules/diskencryption" 
  kvname = "identitykv${substr(var.location,0,8)}"
  kvkeyname = "identity-deskey-${var.location}"
  tenantid = local.tenantid
  desname = "identity-des-${var.location}"
  location = var.location
  resource_group_name = azurerm_resource_group.diskencryptionrg.name
}

module "addsvm1" {
  source = "./modules/winservervm" 
  vmname= var.addsvm1name
  adminusername= var.adminusername
  adminpassword= var.windowsadminpassword
  desname= module.diskencryption.desname
  desrg= azurerm_resource_group.diskencryptionrg.name
  privateip= var.addsvm1ip
  subnetname= var.subnetname
  vnetname= var.vnetname
  vmsize= var.vmsize
  vnetrg= var.vnetrg
  zone= "1"
  location = var.location
  resource_group_name = azurerm_resource_group.addsrg.name
  storagetype = "Premium_LRS"
  datadisksizegb = 32
  ospublisher = "MicrosoftWindowsServer"
  osoffer = "WindowsServer"  
  ossku = "2016-Datacenter"
  osversion = "latest"   
}

module "addsvm2" {
  source = "./modules/winservervm" 
  vmname= var.addsvm2name
  adminusername= var.adminusername
  adminpassword= var.windowsadminpassword
  desname= module.diskencryption.desname
  desrg= azurerm_resource_group.diskencryptionrg.name
  privateip= var.addsvm2ip
  subnetname= var.subnetname
  vnetname= var.vnetname
  vmsize= var.vmsize
  vnetrg= var.vnetrg
  zone= "2"
  location = var.location
  resource_group_name = azurerm_resource_group.addsrg.name
  storagetype = "Premium_LRS"
  datadisksizegb = 32
  ospublisher = "MicrosoftWindowsServer"
  osoffer = "WindowsServer"  
  ossku = "2016-Datacenter"
  osversion = "latest"  
}


module "adfsvm1" {
  source = "./modules/winservervm"
  vmname= var.adfsvm1name
  adminusername= var.adminusername
  adminpassword= var.windowsadminpassword
  desname= module.diskencryption.desname
  desrg= azurerm_resource_group.diskencryptionrg.name
  subnetname= var.subnetname
  privateip= var.adfsvm1ip
  vnetname= var.vnetname
  vmsize= var.vmsize
  vnetrg= var.vnetrg
  zone= "1"
  location = var.location
  resource_group_name = azurerm_resource_group.adfsrg.name
  storagetype = "Premium_LRS"
  datadisksizegb = 32
  ospublisher = "MicrosoftWindowsServer"
  osoffer = "WindowsServer"  
  ossku = "2016-Datacenter"
  osversion = "latest"   
}

module "adfsvm2" {
  source = "./modules/winservervm"
  vmname= var.adfsvm2name
  adminusername= var.adminusername
  adminpassword= var.windowsadminpassword
  desname= module.diskencryption.desname
  desrg= azurerm_resource_group.diskencryptionrg.name
  subnetname= var.subnetname
  privateip= var.adfsvm2ip
  vnetname= var.vnetname
  vmsize= var.vmsize
  vnetrg= var.vnetrg
  zone= "2"
  location = var.location
  resource_group_name = azurerm_resource_group.adfsrg.name
  storagetype = "Premium_LRS"
  datadisksizegb = 32
  ospublisher = "MicrosoftWindowsServer"
  osoffer = "WindowsServer"  
  ossku = "2016-Datacenter"
  osversion = "latest"  
}

module "aadcvm1" {
  source = "./modules/winservervm"
  vmname= var.aadcvm1name
  adminusername= var.adminusername
  adminpassword= var.windowsadminpassword
  desname= module.diskencryption.desname
  desrg= azurerm_resource_group.diskencryptionrg.name
  subnetname= var.subnetname
  privateip= var.aadcvm1ip
  vnetname= var.vnetname
  vmsize= var.vmsize
  vnetrg= var.vnetrg
  zone= "1"
  location = var.location
  resource_group_name = azurerm_resource_group.aadcrg.name
  storagetype = "Premium_LRS"
  datadisksizegb = 32
  ospublisher = "MicrosoftWindowsServer"
  osoffer = "WindowsServer"  
  ossku = "2016-Datacenter"
  osversion = "latest"   
}

module "aadcvm2" {
  source = "./modules/winservervm"
  vmname= var.aadcvm2name
  adminusername= var.adminusername
  adminpassword= var.windowsadminpassword
  desname= module.diskencryption.desname
  desrg= azurerm_resource_group.diskencryptionrg.name
  subnetname= var.subnetname
  privateip= var.aadcvm2ip
  vnetname= var.vnetname
  vmsize= var.vmsize
  vnetrg= var.vnetrg
  zone= "2"
  location = var.location
  resource_group_name = azurerm_resource_group.aadcrg.name
  storagetype = "Premium_LRS"
  datadisksizegb = 32
  ospublisher = "MicrosoftWindowsServer"
  osoffer = "WindowsServer"  
  ossku = "2016-Datacenter"
  osversion = "latest"  
}

module "linvm1" {
  source = "./modules/linservervm"
  vmname= var.linvm1name
  adminusername= var.adminusername
  publickey= var.linuxpublickey
  desname= module.diskencryption.desname
  desrg= azurerm_resource_group.diskencryptionrg.name
  subnetname= var.subnetname
  privateip= var.linvm1ip
  vnetname= var.vnetname
  vmsize= var.vmsize
  vnetrg= var.vnetrg
  zone= "1"
  location = var.location
  resource_group_name = azurerm_resource_group.linrg.name
  storagetype = "Premium_LRS"
  datadisksizegb = 32
  ospublisher = "Canonical"
  osoffer = "UbuntuServer"  
  ossku = "16.04-LTS"
  osversion = "latest"  
}

module "linvm2" {
  source = "./modules/linservervm"
  vmname= var.linvm2name
  adminusername= var.adminusername
  publickey= var.linuxpublickey
  desname= module.diskencryption.desname
  desrg= azurerm_resource_group.diskencryptionrg.name
  subnetname= var.subnetname
  privateip= var.linvm2ip
  vnetname= var.vnetname
  vmsize= var.vmsize
  vnetrg= var.vnetrg
  zone= "2"
  location = var.location
  resource_group_name = azurerm_resource_group.linrg.name
  storagetype = "Premium_LRS"
  datadisksizegb = 32
  ospublisher = "Canonical"
  osoffer = "UbuntuServer"  
  ossku = "16.04-LTS"
  osversion = "latest"  
}

