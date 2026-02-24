resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-vnet-demo"
  address_space       = var.vnet_address_space
  location            = var.rg_location
  resource_group_name = var.rg_name
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.prefix}-subnet-demo"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_address_prefixes
}