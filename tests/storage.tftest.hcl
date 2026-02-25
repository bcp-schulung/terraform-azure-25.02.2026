# =============================================================================
# Storage Module Tests
# Tests for Storage Account creation and variable validations
# =============================================================================

mock_provider "azurerm" {}

variables {
  rg_location                       = "westeurope"
  rg_name                           = "rg-test"
  storageaccountname                = "mystorageacct123"
  acc_tier                          = "Standard"
  acc_replication_type              = "LRS"
  infrastructure_encryption_enabled = true
}

# -----------------------------------------------------------------------------
# Resource Creation Tests
# -----------------------------------------------------------------------------

run "storage_creates_account_with_correct_settings" {
  command = plan

  module {
    source = "./modules/storage"
  }

  assert {
    condition     = azurerm_storage_account.example.name == "mystorageacct123"
    error_message = "Storage account name should match the variable"
  }

  assert {
    condition     = azurerm_storage_account.example.location == "westeurope"
    error_message = "Storage account should be in westeurope"
  }

  assert {
    condition     = azurerm_storage_account.example.resource_group_name == "rg-test"
    error_message = "Storage account should be in rg-test resource group"
  }

  assert {
    condition     = azurerm_storage_account.example.account_tier == "Standard"
    error_message = "Storage account tier should be Standard"
  }

  assert {
    condition     = azurerm_storage_account.example.account_replication_type == "LRS"
    error_message = "Storage account replication type should be LRS"
  }
}

run "storage_account_uses_blob_storage_kind" {
  command = plan

  module {
    source = "./modules/storage"
  }

  assert {
    condition     = azurerm_storage_account.example.account_kind == "BlobStorage"
    error_message = "Storage account kind should be BlobStorage"
  }
}

run "storage_has_infrastructure_encryption_enabled" {
  command = plan

  module {
    source = "./modules/storage"
  }

  assert {
    condition     = azurerm_storage_account.example.infrastructure_encryption_enabled == true
    error_message = "Infrastructure encryption should be enabled"
  }
}

run "storage_has_network_rules_deny_default" {
  command = plan

  module {
    source = "./modules/storage"
  }

  assert {
    condition     = azurerm_storage_account.example.network_rules[0].default_action == "Deny"
    error_message = "Network rules should have default_action = Deny"
  }
}

# -----------------------------------------------------------------------------
# Storage Account Name Validation Tests
# -----------------------------------------------------------------------------

run "storage_name_accepts_valid_lowercase_alphanumeric" {
  command = plan

  module {
    source = "./modules/storage"
  }

  variables {
    storageaccountname = "validname123"
  }

  assert {
    condition     = azurerm_storage_account.example.name == "validname123"
    error_message = "Should accept valid lowercase alphanumeric name"
  }
}

run "storage_name_rejects_too_short" {
  command = plan

  module {
    source = "./modules/storage"
  }

  variables {
    storageaccountname = "ab"
  }

  expect_failures = [
    var.storageaccountname,
  ]
}

run "storage_name_rejects_too_long" {
  command = plan

  module {
    source = "./modules/storage"
  }

  variables {
    storageaccountname = "thisnameiswaaaaaytoolong123"
  }

  expect_failures = [
    var.storageaccountname,
  ]
}

run "storage_name_rejects_uppercase" {
  command = plan

  module {
    source = "./modules/storage"
  }

  variables {
    storageaccountname = "InvalidName"
  }

  expect_failures = [
    var.storageaccountname,
  ]
}

run "storage_name_rejects_special_characters" {
  command = plan

  module {
    source = "./modules/storage"
  }

  variables {
    storageaccountname = "invalid-name"
  }

  expect_failures = [
    var.storageaccountname,
  ]
}

run "storage_name_rejects_underscores" {
  command = plan

  module {
    source = "./modules/storage"
  }

  variables {
    storageaccountname = "invalid_name"
  }

  expect_failures = [
    var.storageaccountname,
  ]
}

# -----------------------------------------------------------------------------
# Account Tier Validation Tests
# -----------------------------------------------------------------------------

run "account_tier_accepts_standard" {
  command = plan

  module {
    source = "./modules/storage"
  }

  variables {
    acc_tier = "Standard"
  }

  assert {
    condition     = azurerm_storage_account.example.account_tier == "Standard"
    error_message = "Should accept Standard tier"
  }
}

run "account_tier_accepts_premium" {
  command = plan

  module {
    source = "./modules/storage"
  }

  variables {
    acc_tier = "Premium"
  }

  assert {
    condition     = azurerm_storage_account.example.account_tier == "Premium"
    error_message = "Should accept Premium tier"
  }
}

run "account_tier_rejects_invalid_value" {
  command = plan

  module {
    source = "./modules/storage"
  }

  variables {
    acc_tier = "Basic"
  }

  expect_failures = [
    var.acc_tier,
  ]
}

# -----------------------------------------------------------------------------
# Replication Type Validation Tests
# -----------------------------------------------------------------------------

run "replication_type_accepts_lrs" {
  command = plan

  module {
    source = "./modules/storage"
  }

  variables {
    acc_replication_type = "LRS"
  }

  assert {
    condition     = azurerm_storage_account.example.account_replication_type == "LRS"
    error_message = "Should accept LRS replication type"
  }
}

run "replication_type_accepts_grs" {
  command = plan

  module {
    source = "./modules/storage"
  }

  variables {
    acc_replication_type = "GRS"
  }

  assert {
    condition     = azurerm_storage_account.example.account_replication_type == "GRS"
    error_message = "Should accept GRS replication type"
  }
}

run "replication_type_accepts_ragrs" {
  command = plan

  module {
    source = "./modules/storage"
  }

  variables {
    acc_replication_type = "RAGRS"
  }

  assert {
    condition     = azurerm_storage_account.example.account_replication_type == "RAGRS"
    error_message = "Should accept RAGRS replication type"
  }
}

run "replication_type_accepts_zrs" {
  command = plan

  module {
    source = "./modules/storage"
  }

  variables {
    acc_replication_type = "ZRS"
  }

  assert {
    condition     = azurerm_storage_account.example.account_replication_type == "ZRS"
    error_message = "Should accept ZRS replication type"
  }
}

run "replication_type_rejects_invalid_value" {
  command = plan

  module {
    source = "./modules/storage"
  }

  variables {
    acc_replication_type = "INVALID"
  }

  expect_failures = [
    var.acc_replication_type,
  ]
}

# -----------------------------------------------------------------------------
# Infrastructure Encryption Validation Tests
# -----------------------------------------------------------------------------

run "infrastructure_encryption_rejects_false" {
  command = plan

  module {
    source = "./modules/storage"
  }

  variables {
    infrastructure_encryption_enabled = false
  }

  expect_failures = [
    var.infrastructure_encryption_enabled,
  ]
}

# -----------------------------------------------------------------------------
# Location Validation Tests
# -----------------------------------------------------------------------------

run "storage_location_accepts_westeurope" {
  command = plan

  module {
    source = "./modules/storage"
  }

  variables {
    rg_location = "westeurope"
  }

  assert {
    condition     = azurerm_storage_account.example.location == "westeurope"
    error_message = "Should accept westeurope as valid location"
  }
}

run "storage_location_accepts_eastus" {
  command = plan

  module {
    source = "./modules/storage"
  }

  variables {
    rg_location = "eastus"
  }

  assert {
    condition     = azurerm_storage_account.example.location == "eastus"
    error_message = "Should accept eastus as valid location"
  }
}

run "storage_location_rejects_invalid_region" {
  command = plan

  module {
    source = "./modules/storage"
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

run "storage_rg_name_rejects_empty_string" {
  command = plan

  module {
    source = "./modules/storage"
  }

  variables {
    rg_name = ""
  }

  expect_failures = [
    var.rg_name,
  ]
}

run "storage_rg_name_rejects_invalid_characters" {
  command = plan

  module {
    source = "./modules/storage"
  }

  variables {
    rg_name = "rg@invalid!"
  }

  expect_failures = [
    var.rg_name,
  ]
}

run "storage_rg_name_accepts_valid_name" {
  command = plan

  module {
    source = "./modules/storage"
  }

  variables {
    rg_name = "rg-my_resource.group"
  }

  assert {
    condition     = azurerm_storage_account.example.resource_group_name == "rg-my_resource.group"
    error_message = "Should accept rg name with hyphens, underscores, and periods"
  }
}
