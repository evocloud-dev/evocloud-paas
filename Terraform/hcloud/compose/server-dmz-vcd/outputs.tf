# Retrieve Virtual Cloud desktop IP Address
output "vcd_server_private_ip" {
  description = "Virtual Cloud Desktop Private IP Address"
  value = hcloud_server.vcd_server.network[0].ip
  sensitive = true
}

# Retrieve Virtual Cloud desktop Public IP Address
output "vcd_server_public_ip" {
  description = "Virtual Cloud desktop Public IP Address"
  value = hcloud_server.vcd_server.ipv4_address
  sensitive = true
}