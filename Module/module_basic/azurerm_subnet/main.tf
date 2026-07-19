resource "azurerm_subnet" "Subnet_block" {
  name = var.subnet_name
  virtual_network_name =var.vnet_name
  address_prefixes = var.subnet_address_space
  resource_group_name = var.rg_name
}