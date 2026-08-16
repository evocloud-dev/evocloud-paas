
output "ssh_sgr" {
  value = azurerm_network_security_group.ssh_nsg.id
  sensitive = true
}

output "cntrl_plane_sgr" {
  value = azurerm_network_security_group.cntrl_plane_nsg.id
  sensitive = true
}

output "worker_sgr" {
  value = azurerm_network_security_group.worker_nsg.id
  sensitive = true
}