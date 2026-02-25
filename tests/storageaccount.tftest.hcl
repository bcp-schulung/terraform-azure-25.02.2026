mock_provider "azurerm" {}

variables {
  prefix      = "test"
  rg_location = "westeurope"
  rg_name     = "rg-test"
}


run "storage_account_creates" {
  command = plan

  module {
    source = "./modules/storage"
  }

  assert {
    condition     = azurerm_storage_account.example.infrastructure_encryption_enabled == false
    error_message = "Encryption must be enabled for storage accounts"
  }
  assert {
    condition     = azurerm_storage_account.example.account_kind == "BlobStorage"
    error_message = "Kind of Storage Account must me BlobStorage"
  }

}

run "check_storageaccount_encryption_enabled" {
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