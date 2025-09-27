#--------------------------------------------------
# Expose Server Public IP
#--------------------------------------------------

output "public_ip" {
  description = "Deployer Server Public IP Address"
  value = oci_core_instance.deployer_server.public_ip
  sensitive = true
}