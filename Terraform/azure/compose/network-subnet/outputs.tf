
output "admin_subnet_id" {
  value = azurerm_subnet.admin-subnet.id
  sensitive = true
}

output "admin_subnet_name" {
  value = azurerm_subnet.admin-subnet.name
}

output "backend_subnet_id" {
  value = azurerm_subnet.backend-subnet.id
  sensitive = true
}

output "backend_subnet_name" {
  value = azurerm_subnet.backend-subnet.name
}

output "dmz_subnet_id" {
  value = azurerm_subnet.dmz-subnet.id
  sensitive = true
}

output "dmz_subnet_name" {
  value = azurerm_subnet.dmz-subnet.name
}