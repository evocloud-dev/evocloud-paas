#--------------------------------------------------
# Expose Main VPC ID
#--------------------------------------------------

output "main_rg_id" {
  value = azurerm_resource_group.evocloud-deploy-rg.id
}

output "main_rg_name" {
  value = azurerm_resource_group.evocloud-deploy-rg.name
}

output "main_rg_location" {
  value = azurerm_resource_group.evocloud-deploy-rg.location
}

output "vnet_id" {
  value = azurerm_virtual_network.main.id
}

output "vnet_name" {
  value = azurerm_virtual_network.main.name
}

output "storage_account_name" {
  value = azurerm_storage_account.evocloud-storage.name
}

output "storage_account_id" {
  value = azurerm_storage_account.evocloud-storage.id
}

output "storage_container_name" {
  value = azurerm_storage_container.evocloud-tf-state.name
}

output "storage_container_id" {
  value = azurerm_storage_container.evocloud-tf-state.id
}

