#--------------------------------------------------
# Expose Evocode Runner Information
#--------------------------------------------------

output "private_ip" {
  description = "Evocode Runner Private IP Address"
  value = azurerm_linux_virtual_machine.evocode_runner_server.private_ip_address
  sensitive = true
}

output "hostname_fqdn" {
  value = "${azurerm_linux_virtual_machine.evocode_runner_server.name}.${var.DOMAIN_TLD}"
}