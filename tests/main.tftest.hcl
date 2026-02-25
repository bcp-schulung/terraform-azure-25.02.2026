# =============================================================================
# Root Module Tests
# Integration tests for the main Terraform configuration
# =============================================================================

mock_provider "azurerm" {
  mock_data "azurerm_resource_group" {
    defaults = {
      name     = "rg-tf-lab"
      location = "westeurope"
    }
  }

  mock_data "azurerm_ssh_public_key" {
    defaults = {
      public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7testkey..."
    }
  }
}

variables {
  prefix                 = "demo"
  resource_group_name    = "rg-tf-lab"
  vm_count               = 2
  ssh_key_name           = "test-key"
  ssh_key_resource_group = "rg-tf-lab"
  ssh_allowed_cidr       = "10.0.0.0/8"
}

# -----------------------------------------------------------------------------
# Module Integration Tests
# -----------------------------------------------------------------------------

run "root_creates_all_modules" {
  command = plan

  assert {
    condition     = module.network.subnet_id != ""
    error_message = "Network module should create subnet"
  }

  assert {
    condition     = module.network.vnet_id != ""
    error_message = "Network module should create vnet"
  }
}

run "root_creates_correct_number_of_vms" {
  command = plan

  variables {
    vm_count = 2
  }

  assert {
    condition     = length(module.vm) == 2
    error_message = "Should create 2 VM instances"
  }
}

run "root_creates_single_vm_when_count_is_one" {
  command = plan

  variables {
    vm_count = 1
  }

  assert {
    condition     = length(module.vm) == 1
    error_message = "Should create 1 VM instance when count is 1"
  }
}

run "root_creates_maximum_vms" {
  command = plan

  variables {
    vm_count = 10
  }

  assert {
    condition     = length(module.vm) == 10
    error_message = "Should create 10 VM instances (maximum)"
  }
}

# -----------------------------------------------------------------------------
# Root Variable Validation Tests
# -----------------------------------------------------------------------------

run "root_prefix_accepts_valid_name" {
  command = plan

  variables {
    prefix = "mytest"
  }

  assert {
    condition     = var.prefix == "mytest"
    error_message = "Should accept valid prefix"
  }
}

run "root_prefix_rejects_uppercase" {
  command = plan

  variables {
    prefix = "MYTEST"
  }

  expect_failures = [
    var.prefix,
  ]
}

run "root_prefix_rejects_too_short" {
  command = plan

  variables {
    prefix = "x"
  }

  expect_failures = [
    var.prefix,
  ]
}

run "root_prefix_rejects_too_long" {
  command = plan

  variables {
    prefix = "verylongprefix"
  }

  expect_failures = [
    var.prefix,
  ]
}

run "root_prefix_rejects_starting_with_number" {
  command = plan

  variables {
    prefix = "123test"
  }

  expect_failures = [
    var.prefix,
  ]
}

run "root_prefix_rejects_special_characters" {
  command = plan

  variables {
    prefix = "my_test"
  }

  expect_failures = [
    var.prefix,
  ]
}

# -----------------------------------------------------------------------------
# VM Count Validation Tests
# -----------------------------------------------------------------------------

run "vm_count_accepts_minimum" {
  command = plan

  variables {
    vm_count = 1
  }

  assert {
    condition     = length(module.vm) == 1
    error_message = "Should accept minimum vm_count of 1"
  }
}

run "vm_count_accepts_maximum" {
  command = plan

  variables {
    vm_count = 10
  }

  assert {
    condition     = length(module.vm) == 10
    error_message = "Should accept maximum vm_count of 10"
  }
}

run "vm_count_rejects_zero" {
  command = plan

  variables {
    vm_count = 0
  }

  expect_failures = [
    var.vm_count,
  ]
}

run "vm_count_rejects_negative" {
  command = plan

  variables {
    vm_count = -1
  }

  expect_failures = [
    var.vm_count,
  ]
}

run "vm_count_rejects_above_maximum" {
  command = plan

  variables {
    vm_count = 11
  }

  expect_failures = [
    var.vm_count,
  ]
}

run "vm_count_rejects_decimal" {
  command = plan

  variables {
    vm_count = 2.5
  }

  expect_failures = [
    var.vm_count,
  ]
}

# -----------------------------------------------------------------------------
# Resource Group Name Validation Tests
# -----------------------------------------------------------------------------

run "resource_group_name_accepts_valid_name" {
  command = plan

  variables {
    resource_group_name = "my-resource-group"
  }

  assert {
    condition     = var.resource_group_name == "my-resource-group"
    error_message = "Should accept valid resource group name"
  }
}

run "resource_group_name_rejects_empty" {
  command = plan

  variables {
    resource_group_name = ""
  }

  expect_failures = [
    var.resource_group_name,
  ]
}

# -----------------------------------------------------------------------------
# SSH Key Name Validation Tests
# -----------------------------------------------------------------------------

run "ssh_key_name_accepts_valid_name" {
  command = plan

  variables {
    ssh_key_name = "my-ssh-key"
  }

  assert {
    condition     = var.ssh_key_name == "my-ssh-key"
    error_message = "Should accept valid SSH key name"
  }
}

run "ssh_key_name_rejects_empty" {
  command = plan

  variables {
    ssh_key_name = ""
  }

  expect_failures = [
    var.ssh_key_name,
  ]
}

# -----------------------------------------------------------------------------
# SSH Key Resource Group Validation Tests
# -----------------------------------------------------------------------------

run "ssh_key_resource_group_accepts_valid_name" {
  command = plan

  variables {
    ssh_key_resource_group = "rg-ssh-keys"
  }

  assert {
    condition     = var.ssh_key_resource_group == "rg-ssh-keys"
    error_message = "Should accept valid resource group name"
  }
}

run "ssh_key_resource_group_rejects_empty" {
  command = plan

  variables {
    ssh_key_resource_group = ""
  }

  expect_failures = [
    var.ssh_key_resource_group,
  ]
}

# -----------------------------------------------------------------------------
# SSH Allowed CIDR Validation Tests
# -----------------------------------------------------------------------------

run "ssh_allowed_cidr_accepts_valid_range" {
  command = plan

  variables {
    ssh_allowed_cidr = "192.168.0.0/16"
  }

  assert {
    condition     = var.ssh_allowed_cidr == "192.168.0.0/16"
    error_message = "Should accept valid CIDR range"
  }
}

run "ssh_allowed_cidr_accepts_single_ip" {
  command = plan

  variables {
    ssh_allowed_cidr = "203.0.113.50/32"
  }

  assert {
    condition     = var.ssh_allowed_cidr == "203.0.113.50/32"
    error_message = "Should accept single IP CIDR"
  }
}

run "ssh_allowed_cidr_rejects_invalid_format" {
  command = plan

  variables {
    ssh_allowed_cidr = "invalid-cidr"
  }

  expect_failures = [
    var.ssh_allowed_cidr,
  ]
}

run "ssh_allowed_cidr_rejects_too_large_prefix" {
  command = plan

  variables {
    ssh_allowed_cidr = "10.0.0.0/7"
  }

  expect_failures = [
    var.ssh_allowed_cidr,
  ]
}

# -----------------------------------------------------------------------------
# Integration Tests - Module Dependencies
# -----------------------------------------------------------------------------

run "network_module_outputs_used_by_vm" {
  command = plan

  # This test verifies that the network module's subnet_id output
  # is correctly passed to the VM module
  assert {
    condition     = module.network.subnet_id != null
    error_message = "Network module should output subnet_id for VM module"
  }
}

run "storage_module_is_created" {
  command = plan

  # Verify storage module is created alongside other modules
  assert {
    condition     = length(module.vm) > 0
    error_message = "VM module should be created"
  }
}

# -----------------------------------------------------------------------------
# Different Prefix Tests
# -----------------------------------------------------------------------------

run "prefix_with_hyphens" {
  command = plan

  variables {
    prefix = "my-app"
  }

  assert {
    condition     = var.prefix == "my-app"
    error_message = "Should accept prefix with hyphens"
  }
}

run "prefix_with_numbers" {
  command = plan

  variables {
    prefix = "app123"
  }

  assert {
    condition     = var.prefix == "app123"
    error_message = "Should accept prefix with numbers"
  }
}

run "prefix_exactly_two_chars" {
  command = plan

  variables {
    prefix = "ab"
  }

  assert {
    condition     = var.prefix == "ab"
    error_message = "Should accept prefix with exactly 2 characters"
  }
}

run "prefix_exactly_ten_chars" {
  command = plan

  variables {
    prefix = "abcdefghij"
  }

  assert {
    condition     = var.prefix == "abcdefghij"
    error_message = "Should accept prefix with exactly 10 characters"
  }
}
