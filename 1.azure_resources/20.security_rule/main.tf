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
  name     = "rg_security"
  location = "centralindia"
}

# Network Security Group (NSG):
# A Network Security Group is used to control inbound and outbound network traffic
# using security rules. It can be associated with a subnet or network interface.
resource "azurerm_network_security_group" "nsg_block" {
  name                = "my_nsg"
  resource_group_name = azurerm_resource_group.rg_block.name
  location            = azurerm_resource_group.rg_block.location
}

# Network Security Rule:
# A security rule defines whether specific network traffic is allowed or denied
# based on source, destination, protocol, and port number.
# This rule allows inbound SSH (TCP Port 22) access from any source.
resource "azurerm_network_security_rule" "ssh-allow" {
  resource_group_name         = azurerm_resource_group.rg_block.name
  network_security_group_name = azurerm_network_security_group.nsg_block.name

  name                       = "allow-ssh"
  priority                   = 100
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "22"
  source_address_prefix      = "*"
  destination_address_prefix = "*"
}