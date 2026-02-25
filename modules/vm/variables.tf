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

variable "enable_public_ip" {
  description = "Whether to assign a public IP to the VM. Set to false to reduce attack surface."
  type        = bool
  default     = false
}

variable "ssh_allowed_cidr" {
  description = "CIDR block allowed to SSH into the VM. Use a specific IP range for security."
  type        = string

  validation {
    condition     = can(cidrhost(var.ssh_allowed_cidr, 0))
    error_message = "SSH allowed CIDR must be a valid CIDR notation (e.g., '10.0.0.0/8', '192.168.1.0/24')."
  }

  validation {
    condition     = tonumber(split("/", var.ssh_allowed_cidr)[1]) >= 8 && tonumber(split("/", var.ssh_allowed_cidr)[1]) <= 32
    error_message = "CIDR prefix length must be between /8 and /32. Avoid overly permissive ranges."
  }

  validation {
    condition     = var.ssh_allowed_cidr != "0.0.0.0/0"
    error_message = "SSH access from 0.0.0.0/0 (anywhere) is not allowed. Use a specific IP range for security."
  }
}

variable "public_ip_allocation_method" {
  description = "Allocation method for the Public IP (Static/Dynamic)."
  type        = string
  default     = "Static"

  validation {
    condition     = contains(["Static", "Dynamic"], var.public_ip_allocation_method)
    error_message = "Public IP allocation method must be either 'Static' or 'Dynamic'."
  }
}

variable "public_ip_sku" {
  description = "SKU for the Public IP (Basic/Standard)."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard"], var.public_ip_sku)
    error_message = "Public IP SKU must be either 'Basic' or 'Standard'."
  }
}

variable "private_ip_address_allocation" {
  description = "Private IP address allocation method for the NIC (Dynamic/Static)."
  type        = string
  default     = "Dynamic"

  validation {
    condition     = contains(["Dynamic", "Static"], var.private_ip_address_allocation)
    error_message = "Private IP address allocation must be either 'Dynamic' or 'Static'."
  }
}

variable "admin_username" {
  description = "Admin username for the Linux VM."
  type        = string
  default     = "azureuser"

  validation {
    condition     = length(var.admin_username) >= 1 && length(var.admin_username) <= 64
    error_message = "Admin username must be between 1 and 64 characters."
  }

  validation {
    condition     = !contains(["admin", "administrator", "root", "guest", "test"], lower(var.admin_username))
    error_message = "Admin username cannot be a reserved name (admin, administrator, root, guest, test)."
  }

  validation {
    condition     = can(regex("^[a-z_][a-z0-9_-]*$", var.admin_username))
    error_message = "Admin username must start with a letter or underscore and contain only lowercase letters, numbers, underscores, and hyphens."
  }
}


variable "os_disk_caching" {
  description = "OS disk caching mode."
  type        = string
  default     = "ReadWrite"

  validation {
    condition     = contains(["None", "ReadOnly", "ReadWrite"], var.os_disk_caching)
    error_message = "OS disk caching must be one of: None, ReadOnly, ReadWrite."
  }
}

variable "os_disk_storage_account_type" {
  description = "Storage account type for the OS disk."
  type        = string
  default     = "Standard_LRS"

  validation {
    condition     = contains(["Standard_LRS", "StandardSSD_LRS", "Premium_LRS", "StandardSSD_ZRS", "Premium_ZRS"], var.os_disk_storage_account_type)
    error_message = "OS disk storage account type must be one of: Standard_LRS, StandardSSD_LRS, Premium_LRS, StandardSSD_ZRS, Premium_ZRS."
  }
}

variable "image_publisher" {
  description = "Marketplace image publisher."
  type        = string
  default     = "Canonical"

  validation {
    condition     = length(var.image_publisher) >= 1
    error_message = "Image publisher cannot be empty."
  }
}

variable "image_offer" {
  description = "Marketplace image offer."
  type        = string
  default     = "0001-com-ubuntu-server-jammy"

  validation {
    condition     = length(var.image_offer) >= 1
    error_message = "Image offer cannot be empty."
  }
}

variable "image_sku" {
  description = "Marketplace image SKU."
  type        = string
  default     = "22_04-lts-gen2"

  validation {
    condition     = length(var.image_sku) >= 1
    error_message = "Image SKU cannot be empty."
  }
}

variable "image_version" {
  description = "Marketplace image version."
  type        = string
  default     = "latest"

  validation {
    condition     = length(var.image_version) >= 1
    error_message = "Image version cannot be empty."
  }
}

variable "vm_size" {
  description = "Azure VM size."
  type        = string
  default     = "Standard_B1s"

  validation {
    condition     = can(regex("^Standard_", var.vm_size))
    error_message = "VM size must start with 'Standard_' (e.g., 'Standard_B1s', 'Standard_D2s_v3')."
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

variable "subnet_id" {
  description = "ID of the subnet"
  type        = string

  validation {
    condition     = can(regex("^/subscriptions/[a-f0-9-]+/resourceGroups/[^/]+/providers/Microsoft.Network/virtualNetworks/[^/]+/subnets/[^/]+$", var.subnet_id))
    error_message = "Subnet ID must be a valid Azure subnet resource ID."
  }
}

variable "index" {
  description = "Current index"
  type        = number

  validation {
    condition     = var.index >= 0 && var.index <= 99
    error_message = "Index must be between 0 and 99."
  }

  validation {
    condition     = floor(var.index) == var.index
    error_message = "Index must be a whole number."
  }
}

variable "ssh_public_key" {
  description = "name azure public key"
  type        = string

  validation {
    condition     = can(regex("^ssh-rsa ", var.ssh_public_key)) || can(regex("^ssh-ed25519 ", var.ssh_public_key)) || can(regex("^ecdsa-sha2-", var.ssh_public_key))
    error_message = "SSH public key must be a valid SSH public key starting with 'ssh-rsa', 'ssh-ed25519', or 'ecdsa-sha2-'."
  }
}