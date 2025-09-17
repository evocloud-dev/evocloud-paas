#--------------------------------------------------
# Expose EvoHarbor Platform Information
#--------------------------------------------------

output "private_ip" {
  value = oci_core_instance.evoharbor_server.private_ip
  sensitive = false
}

#output "hostname_fqdn" {
#  value = google_compute_instance.evoharbor_server.hostname
#}