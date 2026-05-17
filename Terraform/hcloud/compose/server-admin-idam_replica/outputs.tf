#--------------------------------------------------
# Expose IDAM Replica Server Information
#--------------------------------------------------

output "private_ip" {
  description = "Idam Replica Private IP Address"
  value = one(hcloud_server.idam_replica_server.network[*].ip)
  sensitive = true
}