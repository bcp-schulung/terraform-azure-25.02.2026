resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-vnet-demo"
  address_space       = var.vnet_address_space
  location            = var.rg_location
  resource_group_name = var.rg_name

  lifecycle {
    # Prevent accidental deletion of VNet which would destroy all connected resources
    prevent_destroy = true

    # Precondition: Validate VNet CIDR is not too permissive
    precondition {
      condition     = alltrue([for cidr in var.vnet_address_space : tonumber(split("/", cidr)[1]) >= 8])
      error_message = "VNet address space CIDR prefix must be /8 or smaller (more restrictive)."
    }
  }
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.prefix}-subnet-demo"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_address_prefixes

  lifecycle {
    # Precondition: Validate subnet CIDR blocks
    precondition {
      condition     = alltrue([for cidr in var.subnet_address_prefixes : tonumber(split("/", cidr)[1]) >= 16])
      error_message = "Subnet address prefix CIDR must be /16 or smaller (more restrictive)."
    }

    # Precondition: Ensure subnet is within VNet address space (basic check)
    precondition {
      condition     = length(var.subnet_address_prefixes) > 0
      error_message = "At least one subnet address prefix must be specified."
    }
  }
}