variable "resourceManagerURI" {
  type = string
  default = "management.usgovcloudapi.net" # management.usgovcloudapi.net
}

variable "oauth_client_id" {
  type = string
  default = "4c0f8449-660e-459b-b89a-483122d3e09b"
}

variable "oauth_client_secret" {
  type = string
  default = "QKAJ2FC.L6e5p6cp_9QBlXqpf98R..6h~H"
}

variable "activeDirectoryURI" {
  type = string
  default = "login.microsoftonline.us" # login.microsoftonline.us
}

variable "tenant_id" {
  type = string
  default = "1d573e87-ce5b-4cff-8606-7def688f45b6"
}

variable "enrollmentAccountName" {
  type = string
  default = "b5f3295f-c2be-4afb-8880-5c0ce9be2db3"
}

variable "subDisplayName" {
  type = string
  default = "terraformtest10"
}

variable "offerType" {
  type = string
  default = "MS-AZR-USGOV-0017P"
}

variable "ownerObjectId" {
  type = string
  default = "b5f3295f-c2be-4afb-8880-5c0ce9be2db3"
}


#az rest --method post \
#  --url "${managementuri}providers/Microsoft.Billing/enrollmentAccounts/${{ steps.setvariables.outputs.enracctname }}/providers/Microsoft.Subscription/createSubscription?api-version=2019-10-01-preview" \
#  --headers "{\"content-type\":\"application/json\"}" \
#  --body "{\"displayName\": \"${{ env.managementsubname }}\", \"offerType\": \"${{ steps.setvariables.outputs.offertype }}\", \"owners\": [{\"objectId\": \"${subownergroupid}\"}]}"
#           

terraform {
  required_providers {
    restapi = {
      source  = "hostname/provider/restapi"
      version = "1.15.0"
    }
  }
}

provider "restapi" {
  uri                  = "https://${var.resourceManagerURI}"
  debug                = true
  write_returns_object = true
  id_attribute         = "Location"

  headers = {
    content-type = "application/json"
  }

  oauth_client_credentials {
      oauth_client_id = var.oauth_client_id
      oauth_client_secret = var.oauth_client_secret
      oauth_token_endpoint = "https://${var.activeDirectoryURI}/${var.tenant_id}/oauth2/v2.0/token"
      oauth_scopes = ["https://${var.resourceManagerURI}/.default"]
  }

  create_method  = "POST"
  use_cookies = true
}

resource "restapi_object" "create_subscription" {
  path = "/providers/Microsoft.Billing/enrollmentAccounts/${var.enrollmentAccountName}/providers/Microsoft.Subscription/createSubscription?api-version=2019-10-01-preview"
  data = "{ \"displayName\": \"${var.subDisplayName}\", \"offerType\": \"${var.offerType}\", \"owners\": [{ \"objectId\": \"${var.ownerObjectId}\" } ]}"
}

output "subscriptionid" {
  value = restapi_object.create_subscription.object_id
}
