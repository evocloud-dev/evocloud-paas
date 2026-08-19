#--------------------------------------------------
# Expose RDP Server Output Values
#--------------------------------------------------
# Retrieve RDP IP Address
output "rdp_server_private_ip" {
  description = "RDP Private IP Address"
  value = azurerm_linux_virtual_machine.rdp_server.private_ip_address
  sensitive = true
}

# Retrieve RDP Public IP Address
output "rdp_server_public_ip" {
  description = "RDP Public IP Address"
  value = azurerm_public_ip.rdp_public_ip.ip_address
  sensitive = true
}