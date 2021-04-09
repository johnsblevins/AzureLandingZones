provider "azurerm" {
  subscription_id = ""
  client_id       = ""
  client_secret   = ""
  tenant_id       = ""
  environment     = "usgovernment"
   features {}
}

locals {
  # The eastus region has 3 availability zones
  zones = toset(["1", "2", "3"])
}

data "azurerm_subnet" "test" {
  name                 = "identity"
  virtual_network_name = "TSDLZ-identity-USGovVirginia"
  resource_group_name  = "TSDLZ-identity-connectivity"
}

resource "azurerm_resource_group" "adds" {
  name     = "adds"
  location = "usgovvirginia"
}

resource "azurerm_network_interface" "myterraformnic" {
  count               = 3
  name                = "myNIC${count.index}"
  location            = "usgovvirginia"
  resource_group_name = azurerm_resource_group.myterraformgroup.name

  ip_configuration {
    name                          = "myNicConfiguration${count.index}"
    subnet_id                     = "${data.azurerm_subnet.test.id}"
    private_ip_address_allocation = "Dynamic"
  }

}

resource "azurerm_virtual_machine" "vm" {
  for_each              = local.zones
  name                  = "vm_az${each.value}"
  location              = "usgovvirginia"
  resource_group_name   = azurerm_resource_group.myterraformgroup.name
  network_interface_ids = ["${azurerm_network_interface.myterraformnic[tonumber(each.value)-1].id}"]
  vm_size               = "Standard_B2ms"
  zones                 = [each.value]

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name              = "myOsDisk${each.value}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  os_profile {
    computer_name  = ""
    admin_username = ""
    admin_password = ""
  }

  os_profile_windows_config {
    provision_vm_agent = true
  }

}