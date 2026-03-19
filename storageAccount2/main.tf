
#Storage account with existing resource group

resource "azurerm_storage_account" "storageaccount" {
  name                     = "rpstorageaccountname"
  resource_group_name      = "RP-RG"  #Existing RG name
  location                 = "central india"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  
}