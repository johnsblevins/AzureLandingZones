variable "vmName"{
  type = string
}
variable "vmSize"{
  type = string
}
variable "privateIP"{
  type = string
}
variable "subnetName"{
  type = string
}
variable "vnetRG"{
  type = string
}
variable "vnetName"{
  type = string
}
variable "adminUsername"{
  type = string
}
variable "adminPassword"{
  type = string
}
variable "desName"{
  type = string
}
variable "desRG"{
  type = string
}
variable "zone"{
  type = string
}
variable "location"{
  type = string
}

data azurerm_virtual_network vnet {
  name = "${var.vnetName}"
  resource_group_name = "${var.vnetRG}"
}

data azurerm_subnet subnet {
  name = "${var.subnetName}"
  resource_resource_group_name = "${var.vnetRG}"
}

data azurerm_disk_encryption_set des {
  name = "${var.desName}"
  resourceresource_group_name = "${var.desRG}"
}

resource azurerm_network_interface nic {
  name = "${var.vmName}-nic1"
  location = resourceGroup().location
  properties ={
    ipConfigurations =[
      {
        name = "${var.vmName}-nic1-ipconfig1"
        properties = {
          privateIPAddress = coalesce("${var.privateIP}")
          privateIPAllocationMethod = "${var.privateIP}" ? "Static" : "Dynamic"
          subnet = {
            id = "${data.subnet.id}"
          }
        }
      }
    ]
  }
}

resource azurerm_virtual_machine vm {
  name = "${var.vmName}"
  location = "${var.location}"
  zones =[
    zone  
  ]
  properties = {
    hardwareProfile ={
      vmSize = "${var.vmSize}"
    }
    networkProfile ={
      networkInterfaces =[
        {
          id = "${data.nic.id}"
          properties ={
            primary =true
          }
        }
      ]
    }
    diagnosticsProfile = {
      bootDiagnostics ={
        enabled = false
      }
    }
    osProfile ={
      adminUsername = "${var.adminUsername}"
      adminPassword = "${var.adminPassword}"
      computerName = "${var.vmName}"
      windowsConfiguration ={}
    }
    securityProfile ={}
    storageProfile ={
      imageReference ={
        publisher = "MicrosoftWindowsServer"
        offer = "WindowsServer"
        sku = "2016-Datacenter"
        version = "latest"
      }
      osDisk ={
        name = "${var.vmName}-osdisk"
        createOption = "FromImage"
        managedDisk = {
          diskEncryptionSet ={
            id = "${data.des.id}"
          }
        }
      }
      dataDisks =[
        {
          name = "${var.vmName}-datadisk-1"
          createOption = "Empty"
          diskSizeGB = 128
          lun = 1       
          managedDisk = {
            diskEncryptionSet ={
              id = "${data.des.id}"
            }
          }   
        }
      ]
    }
  }
}
