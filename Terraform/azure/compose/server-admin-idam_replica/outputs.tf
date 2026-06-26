#--------------------------------------------------
# Expose IDAM Replica Server Information
#--------------------------------------------------

output "private_ip" {
  description = "Idam Server Private IP Address"
  value = azurerm_linux_virtual_machine.idam_replica_server.private_ip_address
  sensitive = true
}