#--------------------------------------------------
# Expose IDAM Server Information
#--------------------------------------------------

output "private_ip" {
  description = "Idam Private IP Address"
  value = one(hcloud_server.idam_server.network[*].ip)
  sensitive = true
}