# Configuring Azure Provider
provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  version = "=2.0.0"
  features {}
}


# Creating resource group
resource "azurerm_resource_group" "example" {
  name     = "network_test"
  location = "uk south"
}

# Creating a virtual network inside my resource group
resource "azurerm_virtual_network" "example" {
  name                = "example-network"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = [var.vpc_address_space]
}




