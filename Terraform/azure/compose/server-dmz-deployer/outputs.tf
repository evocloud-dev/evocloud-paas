#--------------------------------------------------
# Expose Installer ID
#--------------------------------------------------
# Outputs
output "deployer_server_id" {
  value = azurerm_linux_virtual_machine.evo-master.id
  sensitive = true
}

output "deployer_server_ip" {
  value = azurerm_public_ip.evo_master_public_ip.ip_address
}

output "deployer_private_ip" {
  value = azurerm_network_interface.evo-master-nic.private_ip_address
}