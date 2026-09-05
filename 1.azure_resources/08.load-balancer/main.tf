
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

  # Configuration options for the AzureRM provider.
  # Enables the required AzureRM provider features.

  features {}

}


# Creates an Azure Resource Group.
# Definition: A logical container used to organize and manage related Azure resources.

resource "azurerm_resource_group" "rg-block" {

  # Specifies the name of the Resource Group.
  name     = "LoadBalancerRG"

  # Specifies the Azure region where the Resource Group is created.
  location = "centralindia"

}


# Creates an Azure Public IP address.
# Definition: Provides a public IP address that can be used to access an Azure resource from the internet.

resource "azurerm_public_ip" "pip-block" {

  # Specifies the name of the Public IP address.
  name                = "PublicIPForLB"

  # Gets the location from the Resource Group.
  location            = azurerm_resource_group.rg-block.location

  # Gets the Resource Group name from the Resource Group.
  resource_group_name = azurerm_resource_group.rg-block.name

  # Specifies that the Public IP address uses a static allocation.
  allocation_method   = "Static"

}


# Creates an Azure Load Balancer.
# Definition: Distributes incoming network traffic across backend resources.

resource "azurerm_lb" "lb-block" {

  # Specifies the name of the Load Balancer.
  name                = "TestLoadBalancer"

  # Gets the location from the Resource Group.
  location            = azurerm_resource_group.rg-block.location

  # Gets the Resource Group name from the Resource Group.
  resource_group_name = azurerm_resource_group.rg-block.name

  # Defines the frontend IP configuration of the Load Balancer.
  # Definition: Specifies the IP address through which clients can access the Load Balancer.

  frontend_ip_configuration {

    # Specifies the name of the frontend IP configuration.
    name                 = "PublicIPAddress"

    # Connects the Load Balancer frontend with the Public IP address.
    public_ip_address_id = azurerm_public_ip.pip-block.id

  }

}

