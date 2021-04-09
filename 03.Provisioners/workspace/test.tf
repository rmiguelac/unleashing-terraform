terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "locations" {
    type = map

    default = {
        default = "brazilsouth"
        dev = "westus"
        prod = "eastus"
    }
  
}

resource "azurerm_resource_group" "myrg" {
    name = "terraform-rg"
    location = lookup(var.locations, terraform.workspace)
  
}