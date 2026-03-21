#--------------------------------------------------
# Expose Installer ID
#--------------------------------------------------
# Outputs
output "deployer_server_ip" {
  value = hcloud_server.rdp_server.ipv4_address
}

output "deployer_server_id" {
  value = hcloud_server.rdp_server.id
}

output "deployer_server_name" {
  value = hcloud_server.rdp_server.name
}