variable "entlzprefix"{
  type = string
  default = "elz1"  
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
  default = "f86eed1f-a251-4b29-a8b3-98089b46ce6c"
}
variable "vnetprefix"{
  type = string
  default = "10.0.0.0/23"
}
variable "fwsubnetprefix"{
  type = string
  default = "10.0.0.0/26"
}
variable "fwmanagementsubnetprefix"{
  type = string
  default = "10.0.0.64/26"
}
variable "bastionsubnetprefix"{
  type = string
  default = "10.0.0.128/27"
}
variable "managementsubnetprefix"{
  type = string
  default = "10.0.1.0/26"
}
variable "fwsku"{
  type = string
  default = "Standard"
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

resource "azurerm_resource_group" "connectivityrg" {
  name = "${var.entlzprefix}-sandbox-management-connectivity-${var.location}"
  location = var.location
}

resource "azurerm_virtual_network" "connectivityvnet" {
  name                = "${var.entlzprefix}-sandbox-management-vnet-${var.location}"
  address_space       = [ "${var.vnetprefix}" ]
  location            = azurerm_resource_group.connectivityrg.location
  resource_group_name = azurerm_resource_group.connectivityrg.name
}

resource "azurerm_subnet" "fwsubnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.connectivityrg.name
  virtual_network_name = azurerm_virtual_network.connectivityvnet.name
  address_prefixes     = ["${var.fwsubnetprefix}"]
}

resource "azurerm_subnet" "fwmanagementsubnet" {
  name                 = "AzureFirewallManagementSubnet"
  resource_group_name  = azurerm_resource_group.connectivityrg.name
  virtual_network_name = azurerm_virtual_network.connectivityvnet.name
  address_prefixes     = ["${var.fwmanagementsubnetprefix}"]
}

resource "azurerm_subnet" "bastionsubnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.connectivityrg.name
  virtual_network_name = azurerm_virtual_network.connectivityvnet.name
  address_prefixes     = ["${var.bastionsubnetprefix}"]
}

resource "azurerm_subnet" "managementsubnet" {
  name                 = "management"
  resource_group_name  = azurerm_resource_group.connectivityrg.name
  virtual_network_name = azurerm_virtual_network.connectivityvnet.name
  address_prefixes     = ["${var.managementsubnetprefix}"]
}

resource "azurerm_public_ip" "fwpip" {
  name                = "${var.entlzprefix}-sandbox-management-fw-${var.location}-pip"
  location            = azurerm_resource_group.connectivityrg.location
  resource_group_name = azurerm_resource_group.connectivityrg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "fwmanagementpip" {
  name                = "${var.entlzprefix}-sandbox-management-fw-management-${var.location}-pip"
  location            = azurerm_resource_group.connectivityrg.location
  resource_group_name = azurerm_resource_group.connectivityrg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "bastionpip" {
  name                = "${var.entlzprefix}-sandbox-management-bastion-${var.location}-pip"
  location            = azurerm_resource_group.connectivityrg.location
  resource_group_name = azurerm_resource_group.connectivityrg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall_policy" "fwpolicy" {
  name                = "${var.entlzprefix}-sandbox-management-fw-${var.location}-policy"
  location            = azurerm_resource_group.connectivityrg.location
  resource_group_name = azurerm_resource_group.connectivityrg.name
  sku = "${var.fwsku}"
  threat_intelligence_mode = "Deny"
  }

resource "azurerm_firewall" "fw" {
  name                = "${var.entlzprefix}-sandbox-management-fw-${var.location}-pip"
  location            = azurerm_resource_group.connectivityrg.location
  resource_group_name = azurerm_resource_group.connectivityrg.name
  sku_tier = "${var.fwsku}"
  threat_intel_mode = "Deny"
  firewall_policy_id = azurerm_firewall_policy.fwpolicy.id
  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.fwsubnet.id
    public_ip_address_id = azurerm_public_ip.fwpip.id
  }
  management_ip_configuration {
    name                 = "management-configuration"
    subnet_id            = azurerm_subnet.fwmanagementsubnet.id
    public_ip_address_id = azurerm_public_ip.fwmanagementpip.id
  }
}

resource "azurerm_bastion_host" "bastion" {
  name                = "${var.entlzprefix}-sandbox-management-bastion-${var.location}"
  location            = azurerm_resource_group.connectivityrg.location
  resource_group_name = azurerm_resource_group.connectivityrg.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastionsubnet.id
    public_ip_address_id = azurerm_public_ip.bastionpip.id
  }
}