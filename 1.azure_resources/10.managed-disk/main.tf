terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "5.4.0"
    }
  }
}

provider "azurerm" {
    features {} 
    resource_provider_registrations = "all"
}


resource "azurerm_resource_group" "rg-block" {
  name     = "managed-disk-rg"
  location = "centralindia"
}



resource "azurerm_managed_disk" "source" {
  name                 = "acctestmd1"
  location             = azurerm_resource_group.rg-block.location
  resource_group_name  = azurerm_resource_group.rg-block.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1"

  
}