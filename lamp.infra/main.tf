resource "random_string" "random" {
  length           = 8
  special          = false
}

resource "azurerm_resource_group" "rg" {
  name = local.rg
  location = var.project_location
  tags = local.common_tags
}



resource "azurerm_virtual_network" "vnet" {
  name =  local.vnet
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  address_space = var.address_space
   tags = local.common_tags
}

resource "azurerm_subnet" "subnet" {

  name = local.subnet_1
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name = azurerm_resource_group.rg.name
  address_prefixes = var.address_prefixes
  

}


resource "azurerm_public_ip" "pub" {
  
  name = "${var.project_name}-pub1"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  allocation_method = "Static"

  tags = local.common_tags
}


resource "azurerm_network_interface" "int" {
  name = "${var.project_name}-int"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location

  ip_configuration {
    name = "${var.project_name}-int"
    subnet_id = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.pub.id
  }
}



resource "azurerm_network_security_group" "nsg" {
  name                = "${var.project_name}-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name


 dynamic "security_rule" {

   for_each = var.open_ports
   content {
  name                        = "inbound-${security_rule.key}"
  priority                    = sum([100, security_rule.key])
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = security_rule.value
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
   }
 }


}




resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.int.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}



resource "azurerm_virtual_machine" "vm" {
  name = "${var.project_name}-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  delete_data_disks_on_termination = true
  delete_os_disk_on_termination = true
  network_interface_ids = [azurerm_network_interface.int.id]
  vm_size = var.vm_size

  storage_os_disk {
    create_option = "FromImage"
    name = "${var.project_name}-vm"
    
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_profile {
    computer_name  = random_string.random.result
    admin_username = "azureadmin"
  }


  os_profile_linux_config {
    ssh_keys {
      path     = "/home/azureadmin/.ssh/authorized_keys"
      key_data = file("${path.module}/sshkeys/azure-devops-practise.pub")
    }
    disable_password_authentication = true
 }

}