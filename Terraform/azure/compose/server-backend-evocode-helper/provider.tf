#--------------------------------------------------
# Supported Cloud Provider
#--------------------------------------------------
provider "azurerm" {
  subscription_id = var.AZ_SUBSCRIPTION_ID
  features {}
}

#--------------------------------------------------
# Tfstate Remote State Storage
#--------------------------------------------------
terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "azurerm" {}
}