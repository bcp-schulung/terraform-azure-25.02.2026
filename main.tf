terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "lab" {
  name = var.resource_group_name
}

module "network" {
  source = "./modules/network"

  prefix      = var.prefix
  rg_location = data.azurerm_resource_group.lab.location
  rg_name     = data.azurerm_resource_group.lab.name
}

module "vm" {
  source = "./modules/vm"

  prefix = var.prefix
  subnet_id = module.network.subnet_id
  rg_location = data.azurerm_resource_group.lab.location
  rg_name     = data.azurerm_resource_group.lab.name
}