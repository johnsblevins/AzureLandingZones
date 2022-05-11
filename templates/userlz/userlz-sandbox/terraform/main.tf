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
variable "subid" {
  type = string
  default = "f86eed1f-a251-4b29-a8b3-98089b46ce6c"
}
variable "vnetprefix"{
  type = string
  default = "10.1.0.0/23"
}
variable "appsubnetprefix"{
  type = string
  default = "10.1.0.0/26"
}
variable "datasubnetprefix"{
  type = string
  default = "10.1.0.64/26"
}
variable "managementsubnetprefix"{
  type = string
  default = "10.1.0.128/26"
}
variable "websubnetprefix"{
  type = string
  default = "10.1.0.192/26"
}
variable "fwip"{
  type = string
  default = "10.0.0.4"
}
variable "hubvnetsubid"{
  description = ""
  type = string   
  default = "f86eed1f-a251-4b29-a8b3-98089b46ce6c"
}
variable "hubvnetrgname"{
  description = ""
  type = string 
  default = "elz1-sandbox-management-connectivity-usgovvirginia"

}
variable "hubvnetname"{
  description = ""
  type = string
  default = "elz1-sandbox-management-vnet-usgovvirginia"
}
variable "uniqueid"{
  description = ""
  type = string
  default = "1"
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
  subscription_id = var.subid
  features {}
}

data "azurerm_client_config" "current" {}

data "azurerm_subscription" "current" {}

locals {
  tenantid = data.azurerm_client_config.current.tenant_id
  subname = data.azurerm_subscription.current.display_name
  connectivityrgname = "${local.subname}-connectivity-${var.location}"
  diskencryptionrgname = "${local.subname}-diskencryption-${var.location}"
  vnetname = "${local.subname}-vnet-${var.location}"
  hubtovnetpeername = "${var.hubvnetname}-to-${local.vnetname}"
  vnettohubpeername = "${local.vnetname}-to-${var.hubvnetname}"
  rtname= "${local.subname}-rt-${var.location}"
  nsgname= "${local.subname}-nsg-${var.location}"
  desname= "${local.subname}-des-${var.location}"
  kvname= "${local.subname}kv${substr(var.location,0,8)}-${var.uniqueid}"
  kvkeyname= "${local.subname}-kvkey-${var.location}"
  hubvnetid="/subscriptions/${var.hubvnetsubid}/resourceGroups/${var.hubvnetrgname}/providers/Microsoft.Network/virtualNetworks/${var.hubvnetname}"
}

resource "azurerm_resource_group" "connectivityrg" {
  name = local.connectivityrgname
  location = var.location

}

resource "azurerm_resource_group" "diskencryptionrg" {
  name = local.diskencryptionrgname
  location = var.location

}

resource "azurerm_route_table" "rt" {
  name = local.rtname
  location = azurerm_resource_group.connectivityrg.location
  resource_group_name = azurerm_resource_group.connectivityrg.name
  disable_bgp_route_propagation = true
  route {
    name           = "default"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address = var.fwip
  }

}

resource "azurerm_network_security_group" "nsg" {
  name                = local.nsgname
  location = azurerm_resource_group.connectivityrg.location
  resource_group_name = azurerm_resource_group.connectivityrg.name

  security_rule {
    name                       = "allowAll"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

resource "azurerm_virtual_network" "vnet" {
  name                = local.vnetname
  address_space       = [ var.vnetprefix ]
  location            = azurerm_resource_group.connectivityrg.location
  resource_group_name = azurerm_resource_group.connectivityrg.name

}

resource "azurerm_subnet" "managementsubnet" {
  name                 = "management"  
  resource_group_name  = azurerm_resource_group.connectivityrg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.managementsubnetprefix]

}

resource "azurerm_subnet" "appsubnet" {
  name                 = "app"
  resource_group_name  = azurerm_resource_group.connectivityrg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.appsubnetprefix]

}

resource "azurerm_subnet" "websubnet" {
  name                 = "web"
  resource_group_name  = azurerm_resource_group.connectivityrg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.websubnetprefix]

}

resource "azurerm_subnet" "datasubnet" {
  name                 = "data"
  resource_group_name  = azurerm_resource_group.connectivityrg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.datasubnetprefix]

}

resource "azurerm_subnet_route_table_association" "managementsubnetrtassociation" {
  subnet_id      = azurerm_subnet.managementsubnet.id
  route_table_id = azurerm_route_table.rt.id  

}

resource "azurerm_subnet_route_table_association" "websubnetrtassociation" {
  subnet_id      = azurerm_subnet.websubnet.id
  route_table_id = azurerm_route_table.rt.id  

}

resource "azurerm_subnet_route_table_association" "appsubnetrtassociation" {
  subnet_id      = azurerm_subnet.appsubnet.id
  route_table_id = azurerm_route_table.rt.id  

}

resource "azurerm_subnet_route_table_association" "datasubnetrtassociation" {
  subnet_id      = azurerm_subnet.datasubnet.id
  route_table_id = azurerm_route_table.rt.id  

}

resource "azurerm_subnet_network_security_group_association" "managementsubnetnsgassociation" {
  subnet_id                 = azurerm_subnet.managementsubnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id

}

resource "azurerm_subnet_network_security_group_association" "websubnetnsgassociation" {
  subnet_id                 = azurerm_subnet.websubnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id

}

resource "azurerm_subnet_network_security_group_association" "appsubnetnsgassociation" {
  subnet_id                 = azurerm_subnet.appsubnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id

}

resource "azurerm_subnet_network_security_group_association" "datasubnetnsgassociation" {
  subnet_id                 = azurerm_subnet.datasubnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id

}

resource "azurerm_virtual_network_peering" "vnettohubpeer" {
  name                      = local.vnettohubpeername
  resource_group_name       = azurerm_resource_group.connectivityrg.name
  virtual_network_name      = azurerm_virtual_network.vnet.name
  remote_virtual_network_id = local.hubvnetid
}

module "diskencryption" {
  source = "./modules/diskencryption" 
  kvname = local.kvname
  kvkeyname = local.kvkeyname
  tenantid = local.tenantid
  desname = local.desname
  location = var.location
  resource_group_name = azurerm_resource_group.diskencryptionrg.name
}

resource "azurerm_management_lock" "connectivityrglock" {
  name       = "connectivityrglock"
  depends_on = [azurerm_virtual_network_peering.vnettohubpeer]
  scope      = azurerm_resource_group.connectivityrg.id
  lock_level = "ReadOnly"
  notes      = "Locked because it's needed by a third-party"
}

resource "azurerm_management_lock" "diskencryptionrglock" {
  name       = "diskencryptionrglock"
  depends_on = [ module.diskencryption ]
  scope      = azurerm_resource_group.diskencryptionrg.id
  lock_level = "ReadOnly"
  notes      = "Locked because it's needed by a third-party"
}