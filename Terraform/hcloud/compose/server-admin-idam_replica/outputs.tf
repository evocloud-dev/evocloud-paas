#--------------------------------------------------
# Expose IDAM Replica Server Information
#--------------------------------------------------

output "private_ip" {
  description = "Idam Replica Private IP Address"
  value = hcloud_server.idam_replica_server.ipv4_address
  sensitive = true
}