#-------------------------------
# VPC Resource Group
#-------------------------------
resource "azurerm_resource_group" "evocloud-deploy-rg" {
  name = var.AZ_PROJECT_ID
  location = "EAST US"

  tags = {
    environment = "prod"
    project     = var.AZ_PROJECT_ID
  }
}

# Storage Account
resource "azurerm_storage_account" "evocloud-storage" {
  name                     = var.AZ_STORAGE_ACCT  # must be globally unique, 3-24 chars, lowercase alphanumeric
  resource_group_name      = azurerm_resource_group.evocloud-deploy-rg.name
  location                 = azurerm_resource_group.evocloud-deploy-rg.location
  account_tier             = "Standard"              # Standard or Premium
  account_replication_type = "LRS"                  # LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS
  account_kind             = "Storage"

  # Enable HTTPS only
  https_traffic_only_enabled = true

  # Minimum TLS version
  min_tls_version = "TLS1_2"

}


resource "azurerm_storage_container" "evocloud-tf-state" {
  name = "evocloudtfstate"
  storage_account_name = azurerm_storage_account.evocloud-storage.name
  container_access_type = "private"
}

