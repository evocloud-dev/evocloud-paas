
output "security_group_rules" {
  value = azurerm_network_security_group.nsg.id
}