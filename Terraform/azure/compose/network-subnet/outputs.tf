
output "admin_subnet_id" {
  value = azurerm_subnet.admin-subnet.id
}

output "admin_subnet_name" {
  value = azurerm_subnet.admin-subnet.name
}

output "backend_subnet_id" {
  value = azurerm_subnet.backend-subnet.id
}

output "backend_subnet_name" {
  value = azurerm_subnet.backend-subnet.name
}

output "dmz_subnet_id" {
  value = azurerm_subnet.dmz-subnet.id
}

output "dmz_subnet_name" {
  value = azurerm_subnet.dmz-subnet.name
}