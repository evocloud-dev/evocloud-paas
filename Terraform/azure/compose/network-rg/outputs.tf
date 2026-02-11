#--------------------------------------------------
# Expose Main VPC ID
#--------------------------------------------------

output "main_rg_id" {
  value = azurerm_resource_group.evocloud-rg.id
}

output "main_rg_name" {
  value = azurerm_resource_group.evocloud-rg.name
}