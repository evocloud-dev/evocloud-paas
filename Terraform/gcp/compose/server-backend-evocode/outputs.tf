#--------------------------------------------------
# Expose EvoCode VCS Platform
#--------------------------------------------------

output "private_ip" {
  value = google_compute_instance.evocode_server.network_interface[0].network_ip
  sensitive = true
}

output "hostname_fqdn" {
  value = google_compute_instance.evocode_server.hostname
}