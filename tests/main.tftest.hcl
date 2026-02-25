# =============================================================================
# Root Module Tests
# Variable validation tests for the main Terraform configuration
# (Azure provider validates SSH keys internally, so integration tests requiring
# VM planning are limited to validation tests)
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
      public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCtest"
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

# =============================================================================
# Variable Validation Tests
# =============================================================================

# -----------------------------------------------------------------------------
# Prefix Validation Tests
# -----------------------------------------------------------------------------

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

run "ssh_key_resource_group_rejects_empty" {
  command = plan

  variables {
    ssh_key_resource_group = ""
  }

  expect_failures = [
    var.ssh_key_resource_group,
  ]
}
