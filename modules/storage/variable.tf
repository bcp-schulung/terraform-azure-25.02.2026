variable "rg_name" {
  description = "Name of the existing Azure Resource Group to deploy into."
  type        = string
  default     = "rg-tf-lab"

  validation {
    condition     = length(var.rg_name) >= 1 && length(var.rg_name) <= 90
    error_message = "Resource group name must be between 1 and 90 characters."
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9._-]+$", var.rg_name))
    error_message = "Resource group name can only contain alphanumeric characters, periods, underscores, and hyphens."
  }
}

variable "rg_location" {
  description = "Location of the ressource group"
  type        = string

  validation {
    condition = contains([
      "eastus", "eastus2", "westus", "westus2", "westus3",
      "centralus", "northcentralus", "southcentralus", "westcentralus",
      "canadacentral", "canadaeast",
      "brazilsouth",
      "northeurope", "westeurope", "uksouth", "ukwest",
      "francecentral", "francesouth",
      "switzerlandnorth", "switzerlandwest",
      "germanywestcentral", "germanynorth",
      "norwayeast", "norwaywest",
      "swedencentral",
      "polandcentral",
      "eastasia", "southeastasia",
      "japaneast", "japanwest",
      "australiaeast", "australiasoutheast", "australiacentral",
      "centralindia", "southindia", "westindia",
      "koreacentral", "koreasouth",
      "uaenorth", "uaecentral",
      "southafricanorth", "southafricawest",
      "qatarcentral"
    ], lower(var.rg_location))
    error_message = "Location must be a valid Azure region (e.g., 'eastus', 'westeurope', 'northeurope')."
  }
}

variable "acc_tier" {
  description = "Standard tier"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "Premium"], var.acc_tier)
    error_message = "Account tier must be either 'Standard' or 'Premium'."
  }
}

variable "acc_replication_type" {
  description = "Storage account replication type for data redundancy."
  type        = string
  default     = "LRS"

  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.acc_replication_type)
    error_message = "Account replication type must be one of: LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS."
  }

  validation {
    condition     = var.acc_replication_type != "LRS" || var.acc_replication_type == "LRS"
    error_message = "Warning: LRS provides no geo-redundancy. Consider using GRS, RAGRS, ZRS, GZRS, or RAGZRS for production workloads."
  }
}

variable "storageaccountname" {
  description = "Name of the storageaccount"
  type        = string
  default     = "test"

  validation {
    condition     = length(var.storageaccountname) >= 3 && length(var.storageaccountname) <= 24
    error_message = "Storage account name must be between 3 and 24 characters long."
  }

  validation {
    condition     = can(regex("^[a-z0-9]+$", var.storageaccountname))
    error_message = "Storage account name can only contain lowercase letters and numbers."
  }
}

variable "infrastructure_encryption_enabled" {
  description = "Enable infrastructure encryption for double encryption at rest. Must be true for compliance."
  type        = bool
  default     = true

  validation {
    condition     = var.infrastructure_encryption_enabled == true
    error_message = "Infrastructure encryption must be enabled (true). This is required for security compliance."
  }
}