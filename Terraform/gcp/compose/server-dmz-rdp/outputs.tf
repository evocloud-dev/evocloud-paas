# Retrieve RDP IP Address
output "rdp_server_private_ip" {
  description = "RDP Private IP Address"
  value = google_compute_instance.rdp_server.network_interface[0].network_ip
  sensitive = true
}

# Retrieve RDP Public IP Address
output "rdp_server_public_ip" {
  description = "RDP Public IP Address"
  value = google_compute_address.rdp_server_eip.address
  sensitive = true
}