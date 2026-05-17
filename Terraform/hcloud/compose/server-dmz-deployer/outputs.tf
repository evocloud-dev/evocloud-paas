#--------------------------------------------------
# Expose Installer ID
#--------------------------------------------------
# Outputs
output "deployer_server_ip" {
  value = hcloud_server.deployer_server.ipv4_address
}

output "deployer_server_id" {
  value = hcloud_server.deployer_server.id
}

output "deployer_server_name" {
  value = hcloud_server.deployer_server.name
}

output "hcloud_ssh_key_name" {
  value = try(hcloud_ssh_key.pub_key.name, null)
}

output "hcloud_ssh_key_id" {
  value = try(hcloud_ssh_key.pub_key.id, null)
}