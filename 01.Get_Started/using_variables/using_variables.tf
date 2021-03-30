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

resource "azurerm_resource_group" "rg1" {
  name = "learn-terraform-rg"
  location = "brazilsouth"

  tags = {
    "environment" = "terraform"
    "owner" = "rui"
  }
}

resource "azurerm_network_security_group" "nsg1" {
  name = var.nsg_name
  location = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name

  tags = {
    "environment" = "terraform"
    "owner": "rui"
  }
}

resource "azurerm_network_security_rule" "nsr1" {
  name = var.nsr_name
  priority = 1022
  direction = "Inbound"
  access = "Allow"
  protocol = "Tcp"
  source_port_range = "*"
  destination_port_range = "22"
  source_address_prefix = "*"
  destination_address_prefix = "*"
  resource_group_name = azurerm_resource_group.rg1.name
  network_security_group_name = azurerm_network_security_group.nsg1.name
  
}