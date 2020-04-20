provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "p3_Development" {
  name     = "p3_Development_resources"
  location = "uk south"
}

module "app_dev_linuxservers" {
  source                        = "Azure/compute/azurerm"
  resource_group_name           = azurerm_resource_group.p3_Development.name
  vm_hostname                   = "p3_Development_vm"
  nb_public_ip                  = 0
  remote_port                   = "22"
  nb_instances                  = 3
  vm_os_publisher               = "Canonical"
  vm_os_offer                   = "UbuntuServer"
  vm_os_sku                     = "18.04-LTS"
  admin_password                = "password"
  admin_username                = "app-dev"
  vnet_subnet_id                = module.app_dev_network.vnet_subnets[0]
  boot_diagnostics              = true
  delete_os_disk_on_termination = true
  nb_data_disk                  = 1
  data_disk_size_gb             = 30
  data_sa_type                  = "Premium_LRS"
  enable_ssh_key                = true
  ssh_key                       = "~/.ssh/id_rsa.pub"
  vm_size                       = "Standard_B1ms"

  tags = {
    environment = "dev"
    costcenter  = "it"
  }

  enable_accelerated_networking = false
}

module "app_dev_network" {
  source              = "Azure/network/azurerm"
  version             = "3.0.1"
  resource_group_name = azurerm_resource_group.p3_Development.name
  subnet_prefixes     = ["10.0.1.0/24"]
}

output "app-dev-linux_vm_private_ips" {
  value = module.app_dev_linuxservers.network_interface_private_ip
}


output "app-dev-linux_vm_public_ip" {
  value = module.app_dev_linuxservers.public_ip_address
}

