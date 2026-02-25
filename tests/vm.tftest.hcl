# =============================================================================
# VM Module Tests
# Tests for variable validations (Azure provider validates SSH keys internally,
# so tests requiring VM resource planning are limited to validation tests)
# =============================================================================

mock_provider "azurerm" {}

variables {
  prefix                        = "test"
  rg_location                   = "westeurope"
  rg_name                       = "rg-test"
  subnet_id                     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet"
  ssh_public_key                = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCtest"
  ssh_allowed_cidr              = "10.0.0.0/8"
  index                         = 0
  enable_public_ip              = false
  public_ip_allocation_method   = "Static"
  public_ip_sku                 = "Standard"
  private_ip_address_allocation = "Dynamic"
  admin_username                = "azureuser"
  os_disk_caching               = "ReadWrite"
  os_disk_storage_account_type  = "Standard_LRS"
  image_publisher               = "Canonical"
  image_offer                   = "0001-com-ubuntu-server-jammy"
  image_sku                     = "22_04-lts-gen2"
  image_version                 = "latest"
  vm_size                       = "Standard_B1s"
}

# =============================================================================
# Variable Validation Tests (expect_failures)
# These tests fail during variable validation, before provider validation
# =============================================================================

# -----------------------------------------------------------------------------
# Prefix Validation Tests
# -----------------------------------------------------------------------------

run "vm_prefix_rejects_uppercase" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    prefix = "MYVM"
  }

  expect_failures = [
    var.prefix,
  ]
}

run "vm_prefix_rejects_too_short" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    prefix = "x"
  }

  expect_failures = [
    var.prefix,
  ]
}

run "vm_prefix_rejects_too_long" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    prefix = "verylongprefix"
  }

  expect_failures = [
    var.prefix,
  ]
}

run "vm_prefix_rejects_starting_with_number" {
  command = plan

  module {
    source = "./modules/vm"
  }

  variables {
    prefix = "1vm"
  }

  expect_failures = [
    var.prefix,
  ]
}
