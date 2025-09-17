# Retrieve RDP IP Address
output "rdp_server_private_ip" {
  description = "RDP Private IP Address"
  value = oci_core_instance.rdp_server.private_ip
  sensitive = true
}

# Retrieve RDP Public IP Address
output "rdp_server_public_ip" {
  description = "RDP Public IP Address"
  value = oci_core_instance.rdp_server.public_ip
  sensitive = true
}