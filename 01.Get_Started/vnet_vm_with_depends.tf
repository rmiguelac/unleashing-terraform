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

variable "admin_username" {
    type = string
    description = "Admin user name for virtual machine"
  
}

variable "admin_password" {
    type = string
    description = "Password must meet azure complexity requirements"
  
}

resource "azurerm_subnet" "subnet1" {
    name = "subnet1"
    resource_group_name = azurerm_resource_group.first_rg.name
    virtual_network_name = azurerm_virtual_network.first_vnet.name
    address_prefixes = ["10.0.1.0/24"]

}

resource "azurerm_public_ip" "publicip" {
    name = "myPublicIP"
    location = "brazilsouth"
    resource_group_name = azurerm_resource_group.first_rg.name
    allocation_method = "Static"
  
    tags = {
      "environment" = "terraform"
    }
}

resource "azurerm_network_security_group" "nsg" {
    name = "myNSG"
    location = "brazilsouth"
    resource_group_name = azurerm_resource_group.first_rg.name

    tags = {
        "environment" = "terraform"
    }
  
}

resource "azurerm_network_security_rule" "secrule" {
    access = "Allow"
    description = "Description"
    destination_address_prefix = "*"
    destination_port_range = "22"
    direction = "Inbound"
    name = "SSH"
    priority = 1001
    protocol = "Tcp"
    source_address_prefix = "*"
    source_port_range = "*"
    resource_group_name = azurerm_resource_group.first_rg.name
    network_security_group_name = azurerm_network_security_group.nsg.name
  
}

resource "azurerm_network_interface" "nic" {
    name = "myNIC"
    location = "brazilsouth"
    resource_group_name = azurerm_resource_group.first_rg.name
  
    ip_configuration {
      name = "myNICConfig"
      subnet_id = azurerm_subnet.subnet1.id
      private_ip_address_allocation = "dynamic"
      public_ip_address_id = azurerm_public_ip.publicip.id
    }
}

resource "azurerm_virtual_machine" "vm" {
    name = "myVM"
    location = "brazilsouth"
    resource_group_name = azurerm_resource_group.first_rg.name
    network_interface_ids = [azurerm_network_interface.nic.id]
    vm_size = "Standard_DS1_v2"

    storage_os_disk {
        name = "myOSDisk"
        caching = "ReadWrite"
        create_option = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer = "UbuntuServer"
        sku = "16.04.0-LTS"
        version = "latest"
    }

    os_profile {
        computer_name = "myVM"
        admin_password = var.admin_password
        admin_username = var.admin_username
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }
  
}

data "azurerm_public_ip" "ip" {
    name = azurerm_public_ip.publicip.name
    resource_group_name = azurerm_virtual_machine.vm.resource_group_name
    depends_on = [
      azurerm_virtual_machine.vm
    ]
  
}