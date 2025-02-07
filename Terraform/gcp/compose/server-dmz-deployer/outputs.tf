#--------------------------------------------------
# Expose DEPLOYER Server Information
#--------------------------------------------------

output "private_ip" {
  description = "Deployer Server Private IP Address"
  value = google_compute_instance.deployer_server.network_interface[0].network_ip
  sensitive = true
}

#--------------------------------------------------
# Expose Server Public IP
#--------------------------------------------------

output "public_ip" {
  description = "Deployer Server Public IP Address"
  value = google_compute_address.deployer_server_eip.address
  sensitive = true
}