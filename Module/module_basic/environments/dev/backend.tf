terraform {
  backend "azurerm" {
    resource_group_name = "RP_backend_rg"
    storage_account_name = "backendsta"
    container_name = "backendcontainer"
    key = "dev-statefile"

  }
}