# Retrieve VCD IP Address
output "vcd_server_private_ip" {
  description = "RDP Private IP Address"
  value = oci_core_instance.vcd_server.private_ip
  sensitive = true
}

# Retrieve VCD Public IP Address
output "vcd_server_public_ip" {
  description = "RDP Public IP Address"
  value = oci_core_instance.vcd_server.public_ip
  sensitive = true
}