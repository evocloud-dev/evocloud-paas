#--------------------------------------------------
# Expose VCD Server Output Values
#--------------------------------------------------
# Retrieve VCD IP Address
output "rdp_server_private_ip" {
  description = "VCD Private IP Address"
  value = azurerm_linux_virtual_machine.vcd_server.private_ip_address
  sensitive = true
}

# Retrieve VCD Public IP Address
output "rdp_server_public_ip" {
  description = "VCD Public IP Address"
  value = azurerm_public_ip.vcd_public_ip.ip_address
  sensitive = true
}