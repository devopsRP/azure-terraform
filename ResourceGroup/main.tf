resource "azurerm_resource_group" "rg-terra" {
  name     = "Rp-rg"
  location = "West Europe"
}

provider "azurerm" {
  # Configuration 
  features {}
  
}