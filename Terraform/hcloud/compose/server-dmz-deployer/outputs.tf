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

output "deployer_snapshot_used_id" {
  value = data.hcloud_image.evovm_snapshot.id
}

output "deployer_snapshot_used_name" {
  value = data.hcloud_image.evovm_snapshot.name
}