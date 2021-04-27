terraform {
  backend "azurerm" {
      resource_group_name   = "tf-backend-rg"
      storage_account_name  = "tfackendstorage"
      container_name        = "tf-backend"
      key                   = "tf.test.tfstate"
  }
}

provider "azurerm" {
  features { }
}

resource "azurerm_resource_group" "test-rg" {
    name     = "tf-test-rg"
    location = "brazilsouth"
  
}