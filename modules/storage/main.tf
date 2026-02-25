
resource "azurerm_storage_account" "example" {

  name = var.storageaccountname

  location                 = var.rg_location
  resource_group_name      = var.rg_name
  account_tier             = var.acc_tier
  account_replication_type = var.acc_replication_type

  account_kind = "BlobStorage"

  # AZU-0061: Enable infrastructure encryption for double encryption
  infrastructure_encryption_enabled = true

  # AZU-0012: Network rules with default deny action
  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
  }

  # AZU-0057: Enable logging for queue service
  queue_properties {
    logging {
      delete                = true
      read                  = true
      write                 = true
      version               = "1.0"
      retention_policy_days = 7
    }
  }

}
 