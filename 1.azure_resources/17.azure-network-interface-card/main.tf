terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.76.0"
    }
  }
}

provider "azurerm" {
  # AzureRM provider configuration
  features {
    
  }
}

# Resource Group:
# A Resource Group is a logical container that holds and manages related Azure resources.
resource "azurerm_resource_group" "rg_block" {
  name     = "nic_rg"
  location = "centralindia"
}

# Virtual Network (VNet):
# A Virtual Network is a private network in Azure that enables communication
# between Azure resources and provides network isolation.
resource "azurerm_virtual_network" "vnet_block" {
  resource_group_name = azurerm_resource_group.rg_block.name
  location            = azurerm_resource_group.rg_block.location
  name                = "nic_vnet"
  address_space       = ["10.0.0.0/16"]
}

# Subnet:
# A Subnet is a segmented range of IP addresses within a Virtual Network.
# It is used to organize and isolate resources inside the VNet.
resource "azurerm_subnet" "subnet_block" {
  name                 = "nic_subnet"
  resource_group_name  = azurerm_resource_group.rg_block.name
  virtual_network_name = azurerm_virtual_network.vnet_block.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Network Interface (NIC):
# A Network Interface is a networking component that connects a Virtual Machine
# to a Virtual Network and provides IP configuration for network communication.
resource "azurerm_network_interface" "nic_block" {
  name                = "my_nic"
  location            = azurerm_resource_group.rg_block.location
  resource_group_name = azurerm_resource_group.rg_block.name

  ip_configuration {
    name                          = "ip_congig"
    subnet_id                     = azurerm_subnet.subnet_block.id
    private_ip_address_allocation = "Dynamic"
  }
}