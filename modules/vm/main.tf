resource "azurerm_public_ip" "pip" {
  count               = var.enable_public_ip ? 1 : 0
  name                = "${var.prefix}-pip-demo-${var.index}"
  location            = var.rg_location
  resource_group_name = var.rg_name
  allocation_method   = var.public_ip_allocation_method
  sku                 = var.public_ip_sku

  lifecycle {
    # Precondition: Standard SKU requires Static allocation
    precondition {
      condition     = var.public_ip_sku != "Standard" || var.public_ip_allocation_method == "Static"
      error_message = "Standard SKU public IP requires Static allocation method."
    }
  }
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.prefix}-nsg-demo-${var.index}"
  location            = var.rg_location
  resource_group_name = var.rg_name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.ssh_allowed_cidr
    destination_address_prefix = "*"
  }

  lifecycle {
    # Precondition: Ensure SSH is not open to the world
    precondition {
      condition     = var.ssh_allowed_cidr != "0.0.0.0/0"
      error_message = "SSH access cannot be open to the entire internet (0.0.0.0/0). Use a specific CIDR range."
    }

    # Precondition: Validate CIDR format
    precondition {
      condition     = can(cidrhost(var.ssh_allowed_cidr, 0))
      error_message = "SSH allowed CIDR must be a valid CIDR notation."
    }
  }
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.prefix}-nic-demo-${var.index}"
  location            = var.rg_location
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "${var.prefix}-ipconfig"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = var.private_ip_address_allocation
    public_ip_address_id          = var.enable_public_ip ? azurerm_public_ip.pip[0].id : null
  }
}

resource "azurerm_network_interface_security_group_association" "nsg_association" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "${var.prefix}-vm-demo-${var.index}"
  resource_group_name   = var.rg_name
  location              = var.rg_location
  size                  = var.vm_size
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.nic.id]

  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = var.os_disk_caching
    storage_account_type = var.os_disk_storage_account_type
  }

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  lifecycle {
    # Ignore changes to image version for stability
    ignore_changes = [
      source_image_reference[0].version
    ]

    # Precondition: Validate VM size format
    precondition {
      condition     = can(regex("^Standard_", var.vm_size))
      error_message = "VM size must start with 'Standard_'."
    }

    # Precondition: Validate admin username is not a reserved name
    precondition {
      condition     = !contains(["admin", "administrator", "root", "guest", "test"], lower(var.admin_username))
      error_message = "Admin username cannot be a reserved name (admin, administrator, root, guest, test)."
    }

    # Precondition: Ensure SSH public key is provided
    precondition {
      condition     = length(var.ssh_public_key) > 0
      error_message = "SSH public key must be provided for authentication."
    }
  }
}