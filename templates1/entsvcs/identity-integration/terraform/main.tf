variable "addsvm1name" {
  type = string
  default = "addsvm1"
}
variable "addsvm1ip" {
  type = string
  default = "10.254.4.4"
}
variable "addsvm2name" {
  type = string
  default = "addsvm2"
}
variable "addsvm2ip" {
  type = string
  default = "10.254.4.5"
}
variable "adfsvm1name" {
  type = string
  default = "adfsvm1"
}
variable "adfsvm1ip" {
  type = string
  default = "10.254.4.6"
}
variable "adfsvm2name" {
  type = string
  default = "adfsvm2"
}
variable "adfsvm2ip" {
  type = string
  default = "10.254.4.7"
}
variable "aadcvm1name" {
  type = string
  default = "aadcvm1"
}
variable "aadcvm1ip" {
  type = string
  default = "10.254.4.8"
}
variable "aadcvm2name" {
  type = string
  default = "aadcvm2"
}
variable "aadcvm2ip" {
  type = string
  default = "10.254.4.9"
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
variable "vmSize" {
  type = string
  default = "Standard_B2s"
}
variable "adminUsername"{
  type = string
  default = "azuradmin"
}
variable "adminPassword"{
  type = string
  default = "password123!!"
}
variable "subnetName"{
  type = string
  default = "identity"
}
variable "vnetName"{
  type = string
  default = "TSDLZ-identity-USGovVirginia"
} 
variable "vnetRG" {
  type = string
  default = "TSDLZ-identity-connectivity"
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
  tenantId = "${data.azurerm_client_config.current.tenant_id}"
}

resource "azurerm_resource_group" diskEncryptionRG {
  name = "identity-diskEncryption-${var.location}"
  location = var.location
}

resource "azurerm_resource_group" addsRG {
  name= "identity-adds-${var.location}"
  location= var.location
}

resource "azurerm_resource_group" adfsRG {
  name= "identity-adfs-${var.location}"
  location= var.location
}

resource "azurerm_resource_group" aadcRG {
  name= "identity-aadc-${var.location}"
  location= var.location
}

module "diskEncryption" {
  source = "./modules/diskEncryption" 
  kvName = "identity-KV-${substr(var.location,0,8)}"
  kvKeyName = "identity-DESKey-${var.location}"
  tenantId = "${var.tenantId}"
  diskESName = "identity-DES-${var.location}"
  location = var.location
}

module "addsvm1" {
  source = "./modules/vm" 
  vmName= var.addsvm1name
  adminUsername= var.adminUsername
  adminPassword= var.adminPassword
  desName= diskEncryption.outputs.desName
  desRG= diskEncryptionRG.name
  privateIP= var.addsvm1ip
  subnetName= var.subnetName
  vnetName= var.vnetName
  vmSize= var.vmSize
  vnetRG= var.vnetRG
  zone= "1"
  location = var.location
}

module "addsvm2" {
  source = "./modules/vm" 
  vmName= var.addsvm2name
  adminUsername= var.adminUsername
  adminPassword= var.adminPassword
  desName= diskEncryption.outputs.desName
  desRG= diskEncryptionRG.name
  privateIP= var.addsvm2ip
  subnetName= var.subnetName
  vnetName= var.vnetName
  vmSize= var.vmSize
  vnetRG= var.vnetRG
  zone= "2"
  location = var.location
}


module "adfsvm1" {
  source = "./modules/vm"
  vmName= var.adfsvm1name
  adminUsername= var.adminUsername
  adminPassword= var.adminPassword
  desName= diskEncryption.outputs.desName
  desRG= diskEncryptionRG.name
  subnetName= var.subnetName
  privateIP= var.adfsvm1ip
  vnetName= var.vnetName
  vmSize= var.vmSize
  vnetRG= var.vnetRG
  zone= "1"
  location = var.location
}

module "adfsvm2" {
  source = "./modules/vm"
  vmName= var.adfsvm2name
  adminUsername= var.adminUsername
  adminPassword= var.adminPassword
  desName= diskEncryption.outputs.desName
  desRG= diskEncryptionRG.name
  subnetName= var.subnetName
  privateIP= var.adfsvm2ip
  vnetName= var.vnetName
  vmSize= var.vmSize
  vnetRG= var.vnetRG
  zone= "2"
  location = var.location
}

module "aadcvm1" {
  source = "./modules/vm"
  vmName= var.aadcvm1name
  adminUsername= var.adminUsername
  adminPassword= var.adminPassword
  desName= diskEncryption.outputs.desName
  desRG= diskEncryptionRG.name
  subnetName= var.subnetName
  privateIP= var.aadcvm1ip
  vnetName= var.vnetName
  vmSize= var.vmSize
  vnetRG= var.vnetRG
  zone= "1"
  location = var.location
}

module "aadcvm2" {
  source = "./modules/vm"
  vmName= var.aadcvm2name
  adminUsername= var.adminUsername
  adminPassword= var.adminPassword
  desName= diskEncryption.outputs.desName
  desRG= diskEncryptionRG.name
  subnetName= var.subnetName
  privateIP= var.aadcvm2ip
  vnetName= var.vnetName
  vmSize= var.vmSize
  vnetRG= var.vnetRG
  zone= "2"
  location = var.location
}
