
output "ssh_sgr" {
  value = azurerm_network_security_group.ssh_nsg.id
}

output "cntrl_plane_sgr" {
  value = azurerm_network_security_group.cntrl_plane_nsg.id
}

output "worker_sgr" {
  value = azurerm_network_security_group.worker_nsg.id
}