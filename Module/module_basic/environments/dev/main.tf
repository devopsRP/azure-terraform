#Azurerm Resource group
module "resource_group" {
  source   = "../../azurerm_ResourceGroup"
  rg_name  = var.rg_name
  location = var.location
}

#Azurerm Virtual Network

module "virtal_network" {
  source        = "../../azurerm_Virtual_network"
  vnet_name     = var.vnet_name
  location      = var.location
  vnet_addspace = var.vnet_addspace
  rg_name       = module.resource_group.rg_name
}

#Azurerm Subnet 
module "subnet" {
  source               = "../../azurerm_subnet"
  for_each             = var.subnets
  subnet_name          = each.key
  vnet_name            = module.virtal_network.vnet_name
  rg_name              = module.resource_group.rg_name
  subnet_address_space = each.value

}


