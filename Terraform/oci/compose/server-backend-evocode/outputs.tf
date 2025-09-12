#--------------------------------------------------
# Expose EvoCode GIT Platform
#--------------------------------------------------
output "private_ip" {
  value = oci_core_instance.evocode_server.private_ip
  sensitive = true
}

output "hostname_fqdn" {
  value = "${oci_core_instance.evocode_server.display_name}.${var.DOMAIN_TLD}"
}
