variable "prefix" {
  description = "Prefix used for resource names. Should be unique per student/user to avoid collisions."
  type        = string
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

variable "rg_location" {
  description = "Location of the resource group"
  type        = string
}

variable "rg_name" {
  description = "Name of the resource group"
  type        = string
}