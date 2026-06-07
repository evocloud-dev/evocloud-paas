#--------------------------------------------------
# Expose Evoharbor Information
#--------------------------------------------------

output "private_ip" {
  description = "Evoharbor Private IP Address"
  value = azurerm_linux_virtual_machine.evoharbor_server.private_ip_address
  sensitive = true
}