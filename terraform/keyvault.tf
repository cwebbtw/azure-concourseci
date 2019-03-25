
data "external" "azure_ad_signedinuser_objectid" {
  program                     = ["az", "ad", "signed-in-user", "show", "--query", "{objectId:objectId}"]
}

resource "azurerm_key_vault" "concourse_keyvault" {
  name                        = "concourse-keyvault"
  enabled_for_disk_encryption = true
  location                    = "${azurerm_resource_group.concourse.location}"
  resource_group_name         = "${azurerm_resource_group.concourse.name}"
  tenant_id                   = "${data.azurerm_client_config.current.tenant_id}"

  sku {
    name = "standard"
  }

  access_policy {
    tenant_id = "${data.azurerm_client_config.current.tenant_id}"
    object_id = "${azurerm_user_assigned_identity.concourse_identity.principal_id}"

    secret_permissions = [
      "get",
    ]
  }

  access_policy {
    tenant_id = "${data.azurerm_client_config.current.tenant_id}"
    object_id = "${data.external.azure_ad_signedinuser_objectid.result["objectId"]}"

    secret_permissions = [
      "list",
      "set",
      "get",
      "delete"
    ]
  }
}

resource "azurerm_key_vault_secret" "concourse_keyvault_sample_client_id" {
  name                          = "github-client-id"
  value                         = "sample client id"
  key_vault_id                  = "${azurerm_key_vault.concourse_keyvault.id}"
}

resource "azurerm_key_vault_secret" "concourse_keyvault_sample_client_secret" {
  name                          = "github-client-secret"
  value                         = "sample client secret"
  key_vault_id                  = "${azurerm_key_vault.concourse_keyvault.id}"
}
