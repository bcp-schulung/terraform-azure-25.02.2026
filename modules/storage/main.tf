
resource "azurerm_storage_account" "example" {

  name = var.storageaccountname

  location                 = var.rg_location
  resource_group_name      = var.rg_name
  account_tier             = var.acc_tier
  account_replication_type = var.acc_replication_type

  account_kind = "BlobStorage"

  # AZU-0061: Enable infrastructure encryption for double encryption
  infrastructure_encryption_enabled = var.infrastructure_encryption_enabled

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

  lifecycle {
    # Prevent accidental deletion of storage account with data
    prevent_destroy = true

    # Precondition: Ensure infrastructure encryption is enabled
    precondition {
      condition     = var.infrastructure_encryption_enabled == true
      error_message = "Infrastructure encryption must be enabled for security compliance."
    }

    # Precondition: Warn about LRS replication type
    precondition {
      condition     = contains(["GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.acc_replication_type) || var.acc_replication_type == "LRS"
      error_message = "Consider using geo-redundant storage (GRS, RAGRS, ZRS, GZRS, RAGZRS) for production workloads."
    }
  }
}
 