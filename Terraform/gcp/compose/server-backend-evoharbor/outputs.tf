#--------------------------------------------------
# Expose EvoHarbor Platform Information
#--------------------------------------------------

output "private_ip" {
  value = google_compute_instance.evoharbor_server.network_interface[0].network_ip
  sensitive = true
}

output "hostname_fqdn" {
  value = google_compute_instance.evoharbor_server.hostname
}