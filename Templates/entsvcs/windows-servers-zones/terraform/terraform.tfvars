variable "resourceGroup"{
  description = "The Azure Resource group in which the resources should be deployed"  
  type = string
  default = "adds"
}

variable "location" {
  description = "The Azure Region in which the resources should exist"
  type = string
  default = "usgovvirginia"
}

variable "vmPrefix" {
  description = "The Prefix used for all resources in this example"
  type = string
  default = "myvm"
}

variable "vmCount" {
    description = "The number of VMs to Create"  
    type = number
    default = 5
}

variable "zoneCount" {
    description = "The number of Zones to Stripe"
    type = number
    default = 3
}

variable "vnetRG" {
    description = "The RG of an existing VNET"
    type = string
    default = ""
}

variable "vnetName"
variable "subnetName"
