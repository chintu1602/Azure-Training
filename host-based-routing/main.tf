terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.73.0"
    }
  }
}

provider "azurerm" {
  features {

  }
}

# 1. Resource Group Module
module "rg" {
  source   = "./modules/rg"
  rg_name  = var.rg_name
  location = var.location
}

# 2. Networking Module
module "network" {
  source              = "./modules/network"
  rg_name             = module.rg.name
  location            = module.rg.location
  vnet_name           = var.vnet_name
  vnet_cidr           = var.vnet_cidr
  backend_subnet_cidr = var.backend_subnet_cidr
  gateway_subnet_cidr = var.gateway_subnet_cidr
}

# 3. Virtual Machines Module
module "vm" {
  source            = "./modules/vm"
  rg_name           = module.rg.name
  location          = module.rg.location
  backend_subnet_id = module.network.backend_subnet_id
  vm_size           = var.vm_size
  admin_username    = var.admin_username
  admin_password    = var.admin_password

  # Read application scripts dynamically from scripts/ folder
  fitness_setup_script = file("${path.module}/scripts/fitness/fitness.sh")
  organic_setup_script = file("${path.module}/scripts/organic/organic.sh")
}

# 4. Application Gateway Module
module "agw" {
  source            = "./modules/agw"
  rg_name           = module.rg.name
  location          = module.rg.location
  gateway_subnet_id = module.network.gateway_subnet_id
  fitness_vm_ip     = module.vm.fitness_private_ip
  organic_vm_ip     = module.vm.organic_private_ip
  fitness_hostname  = var.fitness_hostname
  organic_hostname  = var.organic_hostname
}
