#--------------------------------------------------
# Expose Evocode Server Information
#--------------------------------------------------

output "private_ip" {
  description = "Evocode Private IP Address"
  value = one(hcloud_server.evocode_server.network[*].ip)
  sensitive = true
}

output "hostname_fqdn" {
  value = "${hcloud_server.evocode_server.name}.${var.DOMAIN_TLD}"
}