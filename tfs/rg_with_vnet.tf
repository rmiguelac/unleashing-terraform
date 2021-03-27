terraform {
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "=2.46.0"
    }
  }
}

provider "azurerm" { 
  features {} 
}

resource "azurerm_resource_group" "first_rg" {
  name = "learn-terraform-rg"
  location = "brazilsouth"

  tags = {
    "environment" = "terraform"
    "owner" = "rui"
  }
}

resource "azurerm_virtual_network" "first_vnet" {
  name = "terraform-vnet"
  resource_group_name = azurerm_resource_group.first_rg.name  
  location = azurerm_resource_group.first_rg.location
  address_space = ["10.0.0.0/16"]

  tags = {
    "environment" = "terraform"
  }
}