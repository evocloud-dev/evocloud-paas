#--------------------------------------------------
# Expose IDAM Server Information
#--------------------------------------------------

output "private_ip" {
  description = "Idam Private IP Address"
  value = hcloud_server.idam_server.ipv4_address
  sensitive = true
}