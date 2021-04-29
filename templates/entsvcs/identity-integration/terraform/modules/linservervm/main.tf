variable "vmname"{
  type = string
}
variable "vmsize"{
  type = string
}
variable "privateip"{
  type = string
}
variable "subnetname"{
  type = string
}
variable "vnetrg"{
  type = string
}
variable "vnetname"{
  type = string
}
variable "adminusername"{
  type = string
}
variable "publickey"{
  type = string
}
variable "desname"{
  type = string
}
variable "desrg"{
  type = string
}
variable "zone"{
  type = string
}
variable "location"{
  type = string
}
variable "resource_group_name"{
  type = string
}
variable "datadisksizegb"{
  type = number
}
variable "storagetype"{
  type = string
}
variable "ospublisher"{
  type = string
}
variable "osoffer"{
  type = string
}
variable "ossku"{
  type = string  
}
variable "osversion"{
  type = string
}

data "azurerm_subnet" "subnet" {
  name = var.subnetname
  resource_group_name = var.vnetrg
  virtual_network_name = var.vnetname
}

data "azurerm_disk_encryption_set" "des" {
  name = var.desname
  resource_group_name = var.desrg
}

resource "azurerm_network_interface" "nic" {
  name = "${var.vmname}-nic1"
  location = var.location
  resource_group_name = var.resource_group_name
  ip_configuration {
    name = "${var.vmname}-nic1-ipconfig1"
    subnet_id = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = var.privateip != "" ? "Static" : "Dynamic"
    private_ip_address = var.privateip
  }  
}

resource "azurerm_linux_virtual_machine" "vm" {
  name = var.vmname
  location = var.location
  resource_group_name = var.resource_group_name
  zone = var.zone
  size = var.vmsize 
  admin_username = var.adminusername
  network_interface_ids = [ azurerm_network_interface.nic.id ]    
  admin_ssh_key {
    username = var.adminusername
    public_key = var.publickey  
  }
  
  os_disk {
    name = "${var.vmname}-osdisk"
    storage_account_type = var.storagetype
    disk_encryption_set_id = data.azurerm_disk_encryption_set.des.id    
    caching = "ReadWrite"
  }
  
  source_image_reference {
      publisher = var.ospublisher
      offer = var.osoffer      
      sku = var.ossku
      version = var.osversion
  }

}

resource "azurerm_managed_disk" "datadisk1" {
  name = "${var.vmname}-datadisk-1"
  location = var.location
  resource_group_name  = var.resource_group_name  
  storage_account_type = var.storagetype
  disk_encryption_set_id = data.azurerm_disk_encryption_set.des.id
  create_option = "Empty"
  disk_size_gb = var.datadisksizegb
  zones = [ var.zone ]
}

resource "azurerm_virtual_machine_data_disk_attachment" "attachdatadisk1" {
  managed_disk_id    = azurerm_managed_disk.datadisk1.id
  virtual_machine_id = azurerm_linux_virtual_machine.vm.id
  lun                = "1"
  caching            = "ReadWrite"
}