#--------------------------------------------------
# Expose EvoCode Runner Platform Information
#--------------------------------------------------
output "private_ip" {
  value = oci_core_instance.evocode_runner_server.private_ip
  sensitive = false
}

output "hostname_fqdn" {
  value = "${oci_core_instance.evocode_runner_server.display_name}.${var.DOMAIN_TLD}"
}
