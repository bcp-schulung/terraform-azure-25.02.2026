# =============================================================================
# Network Module Tests
# Tests for VNet, Subnet creation and variable validations
# =============================================================================

mock_provider "azurerm" {}

variables {
  prefix      = "test"
  rg_location = "westeurope"
  rg_name     = "rg-test"
}

# -----------------------------------------------------------------------------
# Resource Creation Tests
# -----------------------------------------------------------------------------

run "network_creates_vnet_with_correct_naming" {
  command = plan

  module {
    source = "./modules/network"
  }

  assert {
    condition     = azurerm_virtual_network.vnet.name == "test-vnet-demo"
    error_message = "VNet name should be '${var.prefix}-vnet-demo'"
  }

  assert {
    condition     = azurerm_virtual_network.vnet.location == "westeurope"
    error_message = "VNet should be in westeurope"
  }

  assert {
    condition     = azurerm_virtual_network.vnet.resource_group_name == "rg-test"
    error_message = "VNet should be in rg-test resource group"
  }
}

run "network_creates_subnet_with_correct_naming" {
  command = plan

  module {
    source = "./modules/network"
  }

  assert {
    condition     = azurerm_subnet.subnet.name == "test-subnet-demo"
    error_message = "Subnet name should be '${var.prefix}-subnet-demo'"
  }

  assert {
    condition     = azurerm_subnet.subnet.resource_group_name == "rg-test"
    error_message = "Subnet should be in rg-test resource group"
  }
}

run "network_uses_default_address_spaces" {
  command = plan

  module {
    source = "./modules/network"
  }

  assert {
    condition     = azurerm_virtual_network.vnet.address_space[0] == "10.0.0.0/16"
    error_message = "VNet should use default address space 10.0.0.0/16"
  }

  assert {
    condition     = azurerm_subnet.subnet.address_prefixes[0] == "10.0.1.0/24"
    error_message = "Subnet should use default address prefix 10.0.1.0/24"
  }
}

run "network_uses_custom_address_spaces" {
  command = plan

  module {
    source = "./modules/network"
  }

  variables {
    vnet_address_space       = ["172.16.0.0/16"]
    subnet_address_prefixes  = ["172.16.1.0/24"]
  }

  assert {
    condition     = azurerm_virtual_network.vnet.address_space[0] == "172.16.0.0/16"
    error_message = "VNet should use custom address space"
  }

  assert {
    condition     = azurerm_subnet.subnet.address_prefixes[0] == "172.16.1.0/24"
    error_message = "Subnet should use custom address prefix"
  }
}

# -----------------------------------------------------------------------------
# Prefix Variable Validation Tests
# -----------------------------------------------------------------------------

run "prefix_accepts_valid_lowercase_name" {
  command = plan

  module {
    source = "./modules/network"
  }

  variables {
    prefix = "myapp"
  }

  assert {
    condition     = azurerm_virtual_network.vnet.name == "myapp-vnet-demo"
    error_message = "VNet name should use the valid prefix"
  }
}

run "prefix_accepts_name_with_numbers" {
  command = plan

  module {
    source = "./modules/network"
  }

  variables {
    prefix = "app123"
  }

  assert {
    condition     = azurerm_virtual_network.vnet.name == "app123-vnet-demo"
    error_message = "VNet name should accept prefix with numbers"
  }
}

run "prefix_accepts_name_with_hyphens" {
  command = plan

  module {
    source = "./modules/network"
  }

  variables {
    prefix = "my-app"
  }

  assert {
    condition     = azurerm_virtual_network.vnet.name == "my-app-vnet-demo"
    error_message = "VNet name should accept prefix with hyphens"
  }
}

run "prefix_rejects_uppercase_letters" {
  command = plan

  module {
    source = "./modules/network"
  }

  variables {
    prefix = "TEST"
  }

  expect_failures = [
    var.prefix,
  ]
}

run "prefix_rejects_too_short" {
  command = plan

  module {
    source = "./modules/network"
  }

  variables {
    prefix = "a"
  }

  expect_failures = [
    var.prefix,
  ]
}

run "prefix_rejects_too_long" {
  command = plan

  module {
    source = "./modules/network"
  }

  variables {
    prefix = "verylongprefix"
  }

  expect_failures = [
    var.prefix,
  ]
}

run "prefix_rejects_starting_with_number" {
  command = plan

  module {
    source = "./modules/network"
  }

  variables {
    prefix = "123app"
  }

  expect_failures = [
    var.prefix,
  ]
}

run "prefix_rejects_special_characters" {
  command = plan

  module {
    source = "./modules/network"
  }

  variables {
    prefix = "app_test"
  }

  expect_failures = [
    var.prefix,
  ]
}

# -----------------------------------------------------------------------------
# VNet Address Space Validation Tests
# -----------------------------------------------------------------------------

run "vnet_address_space_rejects_empty_list" {
  command = plan

  module {
    source = "./modules/network"
  }

  variables {
    vnet_address_space = []
  }

  expect_failures = [
    var.vnet_address_space,
  ]
}

run "vnet_address_space_rejects_invalid_cidr" {
  command = plan

  module {
    source = "./modules/network"
  }

  variables {
    vnet_address_space = ["999.999.999.999/16"]
  }

  expect_failures = [
    var.vnet_address_space,
  ]
}

run "vnet_address_space_rejects_too_large_prefix" {
  command = plan

  module {
    source = "./modules/network"
  }

  variables {
    vnet_address_space = ["10.0.0.0/7"]
  }

  expect_failures = [
    var.vnet_address_space,
  ]
}

run "vnet_address_space_rejects_too_small_prefix" {
  command = plan

  module {
    source = "./modules/network"
  }

  variables {
    vnet_address_space = ["10.0.0.0/30"]
  }

  expect_failures = [
    var.vnet_address_space,
  ]
}

run "vnet_address_space_accepts_valid_range" {
  command = plan

  module {
    source = "./modules/network"
  }

  variables {
    vnet_address_space = ["192.168.0.0/16"]
  }

  assert {
    condition     = azurerm_virtual_network.vnet.address_space[0] == "192.168.0.0/16"
    error_message = "VNet should accept valid /16 CIDR"
  }
}

# -----------------------------------------------------------------------------
# Subnet Address Prefix Validation Tests
# -----------------------------------------------------------------------------

run "subnet_address_rejects_empty_list" {
  command = plan

  module {
    source = "./modules/network"
  }

  variables {
    subnet_address_prefixes = []
  }

  expect_failures = [
    var.subnet_address_prefixes,
  ]
}

run "subnet_address_rejects_invalid_cidr" {
  command = plan

  module {
    source = "./modules/network"
  }

  variables {
    subnet_address_prefixes = ["999.999.999.999/24"]
  }

  expect_failures = [
    var.subnet_address_prefixes,
  ]
}

run "subnet_address_rejects_too_large_prefix" {
  command = plan

  module {
    source = "./modules/network"
  }

  variables {
    subnet_address_prefixes = ["10.0.0.0/15"]
  }

  expect_failures = [
    var.subnet_address_prefixes,
  ]
}

run "subnet_address_rejects_too_small_prefix" {
  command = plan

  module {
    source = "./modules/network"
  }

  variables {
    subnet_address_prefixes = ["10.0.0.0/30"]
  }

  expect_failures = [
    var.subnet_address_prefixes,
  ]
}

# -----------------------------------------------------------------------------
# Location Validation Tests
# -----------------------------------------------------------------------------

run "location_accepts_westeurope" {
  command = plan

  module {
    source = "./modules/network"
  }

  variables {
    rg_location = "westeurope"
  }

  assert {
    condition     = azurerm_virtual_network.vnet.location == "westeurope"
    error_message = "Should accept westeurope as valid location"
  }
}

run "location_accepts_eastus" {
  command = plan

  module {
    source = "./modules/network"
  }

  variables {
    rg_location = "eastus"
  }

  assert {
    condition     = azurerm_virtual_network.vnet.location == "eastus"
    error_message = "Should accept eastus as valid location"
  }
}

run "location_rejects_invalid_region" {
  command = plan

  module {
    source = "./modules/network"
  }

  variables {
    rg_location = "invalid-region"
  }

  expect_failures = [
    var.rg_location,
  ]
}

# -----------------------------------------------------------------------------
# Resource Group Name Validation Tests
# -----------------------------------------------------------------------------

run "rg_name_rejects_empty_string" {
  command = plan

  module {
    source = "./modules/network"
  }

  variables {
    rg_name = ""
  }

  expect_failures = [
    var.rg_name,
  ]
}

run "rg_name_rejects_invalid_characters" {
  command = plan

  module {
    source = "./modules/network"
  }

  variables {
    rg_name = "rg@invalid!"
  }

  expect_failures = [
    var.rg_name,
  ]
}

run "rg_name_accepts_valid_name_with_special_chars" {
  command = plan

  module {
    source = "./modules/network"
  }

  variables {
    rg_name = "rg-my_resource.group"
  }

  assert {
    condition     = azurerm_virtual_network.vnet.resource_group_name == "rg-my_resource.group"
    error_message = "Should accept rg name with hyphens, underscores, and periods"
  }
}
