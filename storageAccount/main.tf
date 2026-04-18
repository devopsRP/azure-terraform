#Resource group block

resource "azurerm_resource_group" "Rp-rgroup" {
  name     = "storage-resources"
  location = "Central India"
}


#storage account block

resource "azurerm_storage_account" "storageaccount" {
  name                     = "rpstorageaccountname"
  resource_group_name      = azurerm_resource_group.Rp-rgroup.name
  location                 = azurerm_resource_group.Rp-rgroup.location
  account_tier             = "Standard"
  account_replication_type = "GRS"


} 