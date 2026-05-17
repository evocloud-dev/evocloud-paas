#--------------------------------------------------
# Expose Installer ID
#--------------------------------------------------
# Outputs
output "deployer_server_id" {
  value = azurerm_linux_virtual_machine.evo-master.id
}