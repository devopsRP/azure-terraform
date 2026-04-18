resource "azurerm_resource_group" "rg" {
  name     = "my-rg"
  location = "Central India"
}

resource "azurerm_storage_account" "storage-account" {
    depends_on = [ azurerm_resource_group.rg ]
  name = "implicitstorageaccount"
  location = "Central India"
  resource_group_name = "my-rg"
  account_tier = "Standard"
  account_replication_type = "LRS"
}