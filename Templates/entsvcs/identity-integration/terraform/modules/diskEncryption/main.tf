variable kvName {
  type = string
}
variable kvKeyName {
  type = string
}
variable tenantId {
  type = string 
}
variable diskESName {
  type = string
}
variable location {
  type = string
}

resource azurerm_key_vault kv {
  name = "${var.kvName}"
  location = "${var.location}"
  properties ={    
    createMode = "default"
    tenantId = "${var.tenantId}"
    sku = {
      name = "premium"
      family = "A"
    }
    networkAcls = {
      defaultAction = "Deny"
      ipRules = []
    }        
    enablePurgeProtection = true
    accessPolicies = []
  }
}

resource azurerm_key_vault_key kvKey {
  name = "${var.kvKeyName}"
  dependsOn =[
    kv
  ]
  parent = kv
  properties ={
    keySize = 4096
    kty = "RSA-HSM"
  }
}

resource azurerm_disk_encryption_set diskES {
  name = "${var.diskESName}"
  dependsOn =[
    kvKey
  ]
  location = "${var.location}"
  identity ={
    type = "SystemAssigned"
  }
  properties ={    
    activeKey = {
      keyUrl = kvKey.properties.keyUriWithVersion
      sourceVault = {
        id = kv.id
      }
    }
    encryptionType = "EncryptionAtRestWithCustomerKey"
  }
}

resource  azurerm_key_vault_access_policy kvAccess {
  name = "add"
  dependsOn =[
    diskES
  ]
  parent = kv
  properties ={    
    accessPolicies =[
      {
        objectId = diskES.identity.principalId        
        tenantId = tenantId
        permissions ={
          keys =[
            "list",
            "get",
            "wrapKey",
            "unwrapKey"
          ]
        }
      }
    ]
  }
}

output "desName"{
  value = diskES.name
}


