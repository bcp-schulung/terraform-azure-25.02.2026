data "azurerm_resource_group" "lab" {
  name = var.resource_group_name
}

data "azurerm_ssh_public_key" "existing" {

  name                = var.ssh_key_name
  resource_group_name = var.ssh_key_resource_group
}


module "network" {
  source = "./modules/network"

  prefix      = var.prefix
  rg_location = data.azurerm_resource_group.lab.location
  rg_name     = data.azurerm_resource_group.lab.name
}

module "vm" {
  count  = var.vm_count
  source = "./modules/vm"

  prefix           = var.prefix
  subnet_id        = module.network.subnet_id
  rg_location      = data.azurerm_resource_group.lab.location
  rg_name          = data.azurerm_resource_group.lab.name
  ssh_public_key   = data.azurerm_ssh_public_key.existing.public_key
  ssh_allowed_cidr = var.ssh_allowed_cidr
  index            = count.index
}