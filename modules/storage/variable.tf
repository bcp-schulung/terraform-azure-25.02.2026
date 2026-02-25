variable "rg_name" {
  description = "Name of the existing Azure Resource Group to deploy into."
  type        = string
  default     = "rg-tf-lab"
}

variable "rg_location" {
  description = "Location of the ressource group"
  type        = string
}

variable "acc_tier" {
  description = "Standard tier"
  type        = string
  default     = "Standard"
}

variable "acc_replication_type" {
  description = "value"
  type        = string
  default     = "LRS"
}

variable "storageaccountname" {
  description = "Name of the storageaccount"
  type        = string
  default     = "test"
}