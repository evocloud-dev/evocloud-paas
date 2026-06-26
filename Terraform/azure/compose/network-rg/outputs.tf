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



