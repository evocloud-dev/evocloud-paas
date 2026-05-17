#--------------------------------------------------
# Expose EvoHarbor Platform Information
#--------------------------------------------------
output "private_ip" {
  value = one(hcloud_server.evoharbor_server.network[*].ip)
  sensitive = false
}