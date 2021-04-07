locals {
  rg_types = ["front", "back"]

  tags = {
    "environment" = var.environment
    "owner"       = "rui"
  }
}

resource "azurerm_resource_group" "rg" {
  name     = join("-", [var.environment, "app-${local.rg_types[count.index]}-rg"])
  location = var.location
  count    = length(local.rg_types)

  tags = local.tags

}