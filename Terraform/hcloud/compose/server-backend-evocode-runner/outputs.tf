#--------------------------------------------------
# Expose EvoCode Runner Platform Information
#--------------------------------------------------
output "private_ip" {
  value = hcloud_server.evocode_runner_server.network[*].ip
  sensitive = false
}

output "hostname_fqdn" {
  value = "${hcloud_server.evocode_runner_server.name}.${var.DOMAIN_TLD}"
}