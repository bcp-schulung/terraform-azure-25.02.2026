terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-tf-lab"
    storage_account_name = "tfstate18056"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
    use_azuread_auth     = false
  }
}

provider "azurerm" {
  features {}
}