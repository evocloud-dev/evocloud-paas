#--------------------------------------------------
# Supported Cloud Provider
#--------------------------------------------------
provider "azurerm" {
  client_id       = var.AZ_CLIENT_ID
  client_secret   = var.AZ_CLIENT_SECRET
  subscription_id = var.AZ_SUBSCRIPTION_ID
  tenant_id       = var.AZ_TENANT_ID
  features {}
}

#--------------------------------------------------
# Tfstate Remote State Storage
#--------------------------------------------------
terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "azurerm" {}
}