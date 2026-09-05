
terraform {

  # Defines the Terraform configuration and required providers.
  # Definition: Specifies which providers and provider versions Terraform should use.
  required_providers {

    azurerm = {

      # Specifies the official Azure Resource Manager provider from HashiCorp.
      source  = "hashicorp/azurerm"

      # Specifies the AzureRM provider version to use.
      version = "5.4.0"

    }

  }

}

# Configures the Azure Resource Manager provider.
# Definition: Provides Terraform with the connection and configuration required to manage Azure resources.
provider "azurerm" {

  # *Configuration options*

  # Enables the required AzureRM provider features.
  features {}

}



# Creates an Azure Resource Group.
# Definition: A logical container used to organize and manage related Azure resources.
resource "azurerm_resource_group" "RG-block" {

  # Specifies the name of the resource group.
  name     = "RT-rg"

  # Specifies the Azure region where the resource group is created.
  location = "centralindia"

}



# Creates an Azure Route Table.
# Definition: A collection of custom routes that controls how network traffic is directed in Azure.
resource "azurerm_route_table" "route-table-block" {

  # Specifies the name of the route table.
  name                = "routetable"

  # Uses the same Azure region as the resource group.
  location            = azurerm_resource_group.RG-block.location

  # Associates the route table with the specified resource group.
  resource_group_name = azurerm_resource_group.RG-block.name

  # Defines a custom route inside the route table.
  # Definition: Specifies the destination network and the next hop for traffic.
  route {

    # Specifies the name of the custom route.
    name                   = "route1"

    # Specifies the destination IP address range for this route.
    address_prefix         = "10.100.0.0/14"

    # Specifies that traffic should be sent to a virtual appliance.
    next_hop_type          = "VirtualAppliance"

    # Specifies the IP address of the virtual appliance that receives the traffic.
    next_hop_in_ip_address = "10.10.1.1"

  }

}

