
resource "azurerm_storage_account" "example" {

  name = var.storageaccountname

  location = var.rg_location
  resource_group_name  = var.rg_name
  account_tier             = var.acc_tier
  account_replication_type = var.acc_replication_type
 
 account_kind = "BlobStorage"

}
 