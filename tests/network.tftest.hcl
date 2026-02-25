mock_provider "azurerm" {}

variables {
  prefix      = "test"
  rg_location = "westeurope"
  rg_name     = "rg-test"
}

run "network_creates_vnet_and_subnet" {
  command = plan

  module {
    source = "./modules/network"
  }

  assert {
    condition     = azurerm_virtual_network.vnet.name == "test-vnet-demo"
    error_message = "VNet name should be prefixed correctly"
  }

  assert {
    condition     = azurerm_subnet.subnet.name == "test-subnet-demo"
    error_message = "Subnet name should be prefixed correctly"
  }

  assert {
    condition     = azurerm_virtual_network.vnet.address_space[0] == "10.0.0.0/16"
    error_message = "VNet should use default address space"
  }

  assert {
    condition     = azurerm_subnet.subnet.address_prefixes[0] == "10.0.1.0/24"
    error_message = "Subnet should use default address prefix"
  }
}

run "prefix_validation_rejects_uppercase" {
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

run "prefix_validation_rejects_too_short" {
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
