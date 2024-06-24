terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.108.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 2.52.0"
    }
  }
  
  # backend "azurerm" {
  #   resource_group_name  = "rivadaglobal"
  #   storage_account_name = "rivadaglobal"
  #   container_name       = "infrastructure"
  #   key                  = "terraform/bootstrap.tfstate"
  # }
}

provider "azurerm" {
 features {}
}
