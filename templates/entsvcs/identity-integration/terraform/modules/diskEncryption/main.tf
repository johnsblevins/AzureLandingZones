variable kvname {
  type = string
}
variable kvkeyname {
  type = string
}
variable tenantid {
  type = string 
}
variable desname {
  type = string
}
variable location {
  type = string
}
variable resource_group_name {
  type = string
}
variable sku_name{
  type = string
  default = "premium"
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {
  name = var.kvname
  location = var.location
  resource_group_name = var.resource_group_name
  tenant_id = var.tenantid
  sku_name = var.sku_name      
  enabled_for_disk_encryption = true
  purge_protection_enabled = true
}

resource "azurerm_key_vault_key" "kvkey" {
  name = var.kvkeyname
  key_vault_id = azurerm_key_vault.kv.id
  key_size = 4096
  key_type = "RSA-HSM"  
  depends_on = [
    azurerm_key_vault_access_policy.loggedinuser
  ]

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}

resource "azurerm_disk_encryption_set" "des" {
  name = var.desname
  resource_group_name = var.resource_group_name
  location = var.location
  key_vault_key_id = azurerm_key_vault_key.kvkey.id 

  identity {
    type = "SystemAssigned"
  }
}

resource  "azurerm_key_vault_access_policy" "kvAccess" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id = azurerm_disk_encryption_set.des.identity.0.tenant_id
  object_id = azurerm_disk_encryption_set.des.identity.0.principal_id
  key_permissions = [ "list","get","wrapKey","unwrapKey" ]  
}

resource "azurerm_key_vault_access_policy" "loggedinuser" {
  key_vault_id = azurerm_key_vault.kv.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id

  key_permissions = [
    "get",
    "create",
    "delete"
  ]
}

output "desname" {
  value = azurerm_disk_encryption_set.des.name
}