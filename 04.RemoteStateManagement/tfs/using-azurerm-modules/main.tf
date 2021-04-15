# Terraform configuration

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.55.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "tf-modules-rg" {
  name     = "terraform-modules-rg"
  location = "brazilsouth"

  tags = var.vnet_tags
}



module "vnet" {
  source              = "Azure/vnet/azurerm"
  version             = "2.4.0"
  resource_group_name = azurerm_resource_group.tf-modules-rg.name
  address_space       = ["10.0.0.0/16"]
  subnet_prefixes     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  subnet_names        = ["subnet1", "subnet2", "subnet3"]

  tags = var.vnet_tags

  depends_on = [azurerm_resource_group.tf-modules-rg]
}

module "linuxservers" {
  source               = "Azure/compute/azurerm"
  resource_group_name  = azurerm_resource_group.tf-modules-rg.name
  vm_os_simple         = "UbuntuServer"
  public_ip_dns        = ["sakklearnstfpublicipdns"] // change to a unique name per datacenter region
  vnet_subnet_id       = module.vnet.vnet_subnets[0]
  storage_account_type = "Standard_LRS"

  tags = var.vnet_tags

  depends_on = [azurerm_resource_group.tf-modules-rg]
}