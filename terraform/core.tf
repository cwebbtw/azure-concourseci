
provider "azurerm" {
  version = "=1.23.0"
}

provider "azuread" {
  version = "=0.2.0"
  alias = "azuread"
}

resource "azurerm_resource_group" "concourse" {
  name     = "concourse"
  location = "westeurope"
}

resource "azurerm_user_assigned_identity" "concourse_identity" {
  resource_group_name = "${azurerm_resource_group.concourse.name}"
  location            = "${azurerm_resource_group.concourse.location}"

  name = "concourse_identity"
}

data "azurerm_client_config" "current" { }
