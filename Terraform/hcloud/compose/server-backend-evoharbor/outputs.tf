#--------------------------------------------------
# Expose EvoHarbor Platform Information
#--------------------------------------------------

output "private_ip" {
  value = hcloud_server.evoharbor_server.network[*].ip
  sensitive = false
}