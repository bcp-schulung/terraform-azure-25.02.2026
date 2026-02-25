variable "prefix" {
  description = "Prefix used for resource names. Should be unique per student/user to avoid collisions."
  type        = string
}

variable "enable_public_ip" {
  description = "Whether to assign a public IP to the VM. Set to false to reduce attack surface."
  type        = bool
  default     = true
}

variable "ssh_allowed_cidr" {
  description = "CIDR block allowed to SSH into the VM. Use a specific IP range for security."
  type        = string
}

variable "public_ip_allocation_method" {
  description = "Allocation method for the Public IP (Static/Dynamic)."
  type        = string
  default     = "Static"
}

variable "public_ip_sku" {
  description = "SKU for the Public IP (Basic/Standard)."
  type        = string
  default     = "Standard"
}

variable "private_ip_address_allocation" {
  description = "Private IP address allocation method for the NIC (Dynamic/Static)."
  type        = string
  default     = "Dynamic"
}

variable "admin_username" {
  description = "Admin username for the Linux VM."
  type        = string
  default     = "azureuser"
}


variable "os_disk_caching" {
  description = "OS disk caching mode."
  type        = string
  default     = "ReadWrite"
}

variable "os_disk_storage_account_type" {
  description = "Storage account type for the OS disk."
  type        = string
  default     = "Standard_LRS"
}

variable "image_publisher" {
  description = "Marketplace image publisher."
  type        = string
  default     = "Canonical"
}

variable "image_offer" {
  description = "Marketplace image offer."
  type        = string
  default     = "0001-com-ubuntu-server-jammy"
}

variable "image_sku" {
  description = "Marketplace image SKU."
  type        = string
  default     = "22_04-lts-gen2"
}

variable "image_version" {
  description = "Marketplace image version."
  type        = string
  default     = "latest"
}

variable "vm_size" {
  description = "Azure VM size."
  type        = string
  default     = "Standard_B1s"
}

variable "rg_location" {
  description = "Location of the resource group"
  type        = string
}

variable "rg_name" {
  description = "Name of the resource group"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet"
  type        = string
}

variable "index" {
  description = "Current index"
  type        = number
}

variable "ssh_public_key" {
  description = "name azure public key"
  type        = string
}