#--------------------------------------------------
# Expose IDAM Server Information
#--------------------------------------------------

output "private_ip" {
  description = "Idam Private IP Address"
  value = oci_core_instance.idam_replica_server.private_ip
  sensitive = true
}