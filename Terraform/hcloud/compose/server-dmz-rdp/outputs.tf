#--------------------------------------------------
# Expose RDP Server Output Values
#--------------------------------------------------
# Retrieve RDP IP Address
output "rdp_server_private_ip" {
  description = "RDP Private IP Address"
  value = one(hcloud_server.rdp_server.network[*].ip)
  sensitive = true
}

# Retrieve RDP Public IP Address
output "rdp_server_public_ip" {
  description = "RDP Public IP Address"
  value = hcloud_server.rdp_server.ipv4_address
  sensitive = true
}
