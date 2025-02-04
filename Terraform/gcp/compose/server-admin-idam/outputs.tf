#--------------------------------------------------
# Expose IDAM Server Information
#--------------------------------------------------

output "private_ip" {
  value = google_compute_instance.idam_server.network_interface[0].network_ip
  sensitive = true
}