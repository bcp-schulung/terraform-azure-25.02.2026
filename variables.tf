variable "prefix" {
  description = "Prefix used for resource names. Should be unique per student/user to avoid collisions."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the existing Azure Resource Group to deploy into."
  type        = string
  default     = "rg-tf-lab"
}

variable "vm_count" {
  description = "Number of VMs (and matching NICs/Public IPs) to create."
  type        = number
  default     = 2
}


variable "ssh_key_name" {
  description = "Name of the existing SSH public key resource in Azure."
  type        = string
  default     = "test-key"
}

variable "ssh_key_resource_group" {
  description = "Name of the resource group where the existing SSH public key is located."
  type        = string
  default     = "rg-tf-lab"
}