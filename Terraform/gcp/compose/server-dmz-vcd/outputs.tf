# Retrieve Virtual Cloud desktop IP Address
output "vcd_server_private_ip" {
  description = "Virtual Cloud Desktop Private IP Address"
  value = google_compute_instance.vcd_server.network_interface[0].network_ip
  sensitive = true
}

# Retrieve Virtual Cloud desktop Public IP Address
output "rdp_server_public_ip" {
  description = "Virtual Cloud desktop Public IP Address"
  value = google_compute_address.vcd_server_eip.address
  sensitive = true
}