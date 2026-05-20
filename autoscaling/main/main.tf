terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.73.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {}
}

module "rg" {
  source   = "./modules/rg"
  rg_name  = var.rg_name
  location = var.location
}

module "network" {
  source              = "./modules/network"
  rg_name             = module.rg.rg_name
  location            = module.rg.location
  vnet_name           = var.vnet_name
  address_space       = var.vnet_address_space
  subnet_name         = var.subnet_name
  subnet_prefix       = var.subnet_prefix
}

module "lb" {
  source              = "./modules/lb"
  rg_name             = module.rg.rg_name
  location            = module.rg.location
  lb_pubip            = var.lb_pubip
  lb_name             = var.lb_name
}

module "vmss" {
  source              = "./modules/vmss"
  rg_name             = module.rg.rg_name
  location            = module.rg.location
  vmss_name           = var.vmss_name
  subnet_id           = module.network.subnet_id
  backend_pool_id     = module.lb.backend_pool_id
  admin_username      = var.admin_username
  admin_password      = var.admin_password
}

module "autoscale" {
  source              = "./modules/autoscale"
  rg_name             = module.rg.rg_name
  location            = module.rg.location
  autoscale_name      = var.autoscale_name
  vmss_id             = module.vmss.vmss_id
}

module "servicebus" {
  source              = "./modules/servicebus"
  rg_name             = module.rg.rg_name
  location            = module.rg.location
}

module "monitor" {
  source                  = "./modules/monitor"
  rg_name                 = module.rg.rg_name
  location                = module.rg.location
  vmss_id                 = module.vmss.vmss_id
  servicebus_topic_id     = module.servicebus.topic_id
  email_address           = var.email_address
}