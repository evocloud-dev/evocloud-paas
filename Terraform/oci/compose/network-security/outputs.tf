#--------------------------------------------------
# Expose Network Security Group IDs
#--------------------------------------------------

output "public_nsg" {
  value     = oci_core_network_security_group.evocloud_nsg_public.id
}

output "private_nsg" {
  value = oci_core_network_security_group.evocloud_nsg_private.id
}