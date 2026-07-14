#--------------------------------------------------
# Expose NAT Gateway
#--------------------------------------------------

output "nat_gateway_name" {
  value = azurerm_nat_gateway.nat-gateway.name
}

output "nat_gateway_pip" {
  value = azurerm_public_ip.nat_pip.ip_address
}