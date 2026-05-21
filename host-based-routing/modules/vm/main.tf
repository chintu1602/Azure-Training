# Network Security Group for Virtual Machines
resource "azurerm_network_security_group" "vm_nsg" {
  name                = "vm-nsg"
  location            = var.location
  resource_group_name = var.rg_name

  security_rule {
    name                       = "allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-http"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Network Interfaces
resource "azurerm_network_interface" "fitness_nic" {
  name                = "fitness-nic"
  location            = var.location
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.backend_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "organic_nic" {
  name                = "organic-nic"
  location            = var.location
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.backend_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

# NIC to NSG Associations
resource "azurerm_network_interface_security_group_association" "fitness_nic_nsg" {
  network_interface_id      = azurerm_network_interface.fitness_nic.id
  network_security_group_id = azurerm_network_security_group.vm_nsg.id
}

resource "azurerm_network_interface_security_group_association" "organic_nic_nsg" {
  network_interface_id      = azurerm_network_interface.organic_nic.id
  network_security_group_id = azurerm_network_security_group.vm_nsg.id
}

# Local scripts interpolation into cloud-init
locals {
  fitness_custom_data = <<-EOF
    #!/bin/bash
    mkdir -p /opt/fitness
    cd /opt/fitness
    cat << 'OUTER_EOF' > fitness.sh
    ${var.fitness_setup_script}
    OUTER_EOF
    chmod +x fitness.sh
    ./fitness.sh
  EOF

  organic_custom_data = <<-EOF
    #!/bin/bash
    mkdir -p /opt/organic
    cd /opt/organic
    cat << 'OUTER_EOF' > organic.sh
    ${var.organic_setup_script}
    OUTER_EOF
    chmod +x organic.sh
    ./organic.sh
  EOF
}

# Virtual Machines
resource "azurerm_linux_virtual_machine" "fitness_vm" {
  name                            = "fitness-vm"
  resource_group_name             = var.rg_name
  location                        = var.location
  size                            = var.vm_size
  zone                            = "3"
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.fitness_nic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  custom_data = base64encode(local.fitness_custom_data)
}

resource "azurerm_linux_virtual_machine" "organic_vm" {
  name                            = "organic-vm"
  resource_group_name             = var.rg_name
  location                        = var.location
  size                            = var.vm_size
  zone                            = "3"
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.organic_nic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  custom_data = base64encode(local.organic_custom_data)
}
