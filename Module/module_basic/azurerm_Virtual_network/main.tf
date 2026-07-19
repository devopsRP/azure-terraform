resource "azurerm_virtual_network" "Vnet_block" {
  resource_group_name = var.rg_name
  name = var.vnet_name
  address_space = var.vnet_addspace
  location = var.location

}