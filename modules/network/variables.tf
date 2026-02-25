variable "prefix" {
  description = "Prefix used for resource names. Should be unique per student/user to avoid collisions."
  type        = string

  validation {
    condition     = length(var.prefix) >= 2 && length(var.prefix) <= 10
    error_message = "Prefix must be between 2 and 10 characters long."
  }

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*$", var.prefix))
    error_message = "Prefix must start with a lowercase letter and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "vnet_address_space" {
  description = "Address space for the virtual network."
  type        = list(string)
  default     = ["10.0.0.0/16"]

  validation {
    condition     = length(var.vnet_address_space) > 0
    error_message = "VNet address space must contain at least one CIDR block."
  }

  validation {
    condition     = alltrue([for cidr in var.vnet_address_space : can(cidrhost(cidr, 0))])
    error_message = "All VNet address space entries must be valid CIDR notation (e.g., '10.0.0.0/16')."
  }

  validation {
    condition     = alltrue([for cidr in var.vnet_address_space : tonumber(split("/", cidr)[1]) >= 8 && tonumber(split("/", cidr)[1]) <= 29])
    error_message = "VNet CIDR prefix length must be between /8 and /29."
  }
}

variable "subnet_address_prefixes" {
  description = "Address prefixes for the subnet."
  type        = list(string)
  default     = ["10.0.1.0/24"]

  validation {
    condition     = length(var.subnet_address_prefixes) > 0
    error_message = "Subnet address prefixes must contain at least one CIDR block."
  }

  validation {
    condition     = alltrue([for cidr in var.subnet_address_prefixes : can(cidrhost(cidr, 0))])
    error_message = "All subnet address prefixes must be valid CIDR notation (e.g., '10.0.1.0/24')."
  }

  validation {
    condition     = alltrue([for cidr in var.subnet_address_prefixes : tonumber(split("/", cidr)[1]) >= 16 && tonumber(split("/", cidr)[1]) <= 29])
    error_message = "Subnet CIDR prefix length must be between /16 and /29."
  }
}

variable "rg_location" {
  description = "Location of the resource group"
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

variable "rg_name" {
  description = "Name of the resource group"
  type        = string

  validation {
    condition     = length(var.rg_name) >= 1 && length(var.rg_name) <= 90
    error_message = "Resource group name must be between 1 and 90 characters."
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9._-]+$", var.rg_name))
    error_message = "Resource group name can only contain alphanumeric characters, periods, underscores, and hyphens."
  }
}