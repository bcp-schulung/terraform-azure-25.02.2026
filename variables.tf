variable "prefix" {
  description = "Prefix used for resource names. Should be unique per student/user to avoid collisions."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the existing Azure Resource Group to deploy into."
  type        = string
  default     = "rg-tf-lab"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_address_prefixes" {
  description = "Address prefixes for the subnet."
  type        = list(string)
  default     = ["10.0.1.0/24"]
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

variable "vm_count" {
  description = "Number of VMs (and matching NICs/Public IPs) to create."
  type        = number
  default     = 2
}

variable "vm_size" {
  description = "Azure VM size."
  type        = string
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "Admin username for the Linux VM."
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key file used for VM access. Supports ~ via pathexpand in main.tf."
  type        = string
  default     = "~/.ssh/id_rsa.pub"
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