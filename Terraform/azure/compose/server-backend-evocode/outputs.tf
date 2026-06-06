#--------------------------------------------------
# Expose Evocode Server Information
#--------------------------------------------------

output "private_ip" {
  description = "Evocode Server Private IP Address"
  value = azurerm_linux_virtual_machine.evocode_server.private_ip_address
  sensitive = true
}

output "hostname_fqdn" {
  value = "${azurerm_linux_virtual_machine.evocode_server.name}.${var.DOMAIN_TLD}"
}