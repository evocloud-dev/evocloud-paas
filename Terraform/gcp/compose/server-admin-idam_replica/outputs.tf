#--------------------------------------------------
# Expose IDAM Replica Server Information
#--------------------------------------------------

output "private_ip" {
  value = google_compute_instance.idam_replica_server.network_interface[0].network_ip
  sensitive = true
}