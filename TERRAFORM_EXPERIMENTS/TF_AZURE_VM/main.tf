provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  version = "=2.0.0"
  features {}
}


resource "azurerm_resource_group" "QA_PROJECT3" {
  name     = "${var.prefix}-resources"
  location = "uk south"
}


resource "azurerm_virtual_network" "QA_PROJECT3" {
  name                = "QA_PROJECT3"
  resource_group_name = "QA_PROJECT3"
  location            = "uk south"
  address_space       = ["10.0.0.0/16"]
}


resource "azurerm_subnet" "QA_PROJECT3" {
  name                 = "QA_PROJECT3"
  resource_group_name  = azurerm_resource_group.QA_PROJECT3.name
  virtual_network_name = azurerm_virtual_network.QA_PROJECT3.name
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_public_ip" "QA_PROJECT3" {
  name                = "${var.prefix}-resources"
  location            = azurerm_resource_group.QA_PROJECT3.location
  resource_group_name = azurerm_resource_group.QA_PROJECT3.name
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}

resource "azurerm_network_interface" "QA_PROJECT3" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.QA_PROJECT3.location
  resource_group_name = azurerm_resource_group.QA_PROJECT3.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.QA_PROJECT3.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id         = azurerm_public_ip.QA_PROJECT3.id
  }
}

resource "azurerm_virtual_machine" "QA_PROJECT3" {
  name                  = "${var.prefix}-vm"
  location              = azurerm_resource_group.QA_PROJECT3.location
  resource_group_name   = azurerm_resource_group.QA_PROJECT3.name
  network_interface_ids = [azurerm_network_interface.QA_PROJECT3.id]
  vm_size               = "Standard_DS1_v2"
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "app_development"
    admin_username = "AppDev"
    admin_password = "password"
  }
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data = file("~/.ssh/id_rsa.pub")
      path     = "/home/{username}/.ssh/authorized_keys"

    }
  }
  tags = {
    environment = "staging"
  }
}
