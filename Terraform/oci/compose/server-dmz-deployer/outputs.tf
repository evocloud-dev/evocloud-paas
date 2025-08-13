#--------------------------------------------------
# Expose IDAM Server Information
#--------------------------------------------------
output "public_ip" {
  value = oci_core_instance.deployer_server.public_ip
  sensitive = true
}