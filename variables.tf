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

variable "resource_group_name" {
  description = "Name of the existing Azure Resource Group to deploy into."
  type        = string
  default     = "rg-tf-lab"

  validation {
    condition     = length(var.resource_group_name) >= 1 && length(var.resource_group_name) <= 90
    error_message = "Resource group name must be between 1 and 90 characters."
  }
}

variable "vm_count" {
  description = "Number of VMs (and matching NICs/Public IPs) to create."
  type        = number
  default     = 2

  validation {
    condition     = var.vm_count >= 1 && var.vm_count <= 10
    error_message = "VM count must be between 1 and 10 (inclusive)."
  }

  validation {
    condition     = floor(var.vm_count) == var.vm_count
    error_message = "VM count must be a whole number."
  }
}

variable "ssh_key_name" {
  description = "Name of the existing SSH public key resource in Azure."
  type        = string
  default     = "test-key"

  validation {
    condition     = length(var.ssh_key_name) >= 1
    error_message = "SSH key name cannot be empty."
  }
}

variable "ssh_key_resource_group" {
  description = "Name of the resource group where the existing SSH public key is located."
  type        = string
  default     = "rg-tf-lab"

  validation {
    condition     = length(var.ssh_key_resource_group) >= 1 && length(var.ssh_key_resource_group) <= 90
    error_message = "SSH key resource group name must be between 1 and 90 characters."
  }
}

variable "ssh_allowed_cidr" {
  description = "CIDR block allowed to SSH into the VMs. Use a specific IP range for security."
  type        = string
  default     = "10.0.0.0/8"

  validation {
    condition     = can(cidrhost(var.ssh_allowed_cidr, 0))
    error_message = "SSH allowed CIDR must be a valid CIDR notation (e.g., '10.0.0.0/8', '192.168.1.0/24')."
  }

  validation {
    condition     = tonumber(split("/", var.ssh_allowed_cidr)[1]) >= 8 && tonumber(split("/", var.ssh_allowed_cidr)[1]) <= 32
    error_message = "CIDR prefix length must be between /8 and /32. Avoid overly permissive ranges."
  }
}