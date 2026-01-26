# Retrieve Gateway IP Addresses
output "gateway_server_private_ip" {
  description = "Gateway Private IP Address"
  value = hcloud_server.gateway_server.network[*].ip
  sensitive = true
}

# Retrieve Gateway Public IP Address
output "gateway_server_public_ip" {
  description = "Gateway Public IP Address"
  value = hcloud_server.gateway_server.ipv4_address
  sensitive = true
}