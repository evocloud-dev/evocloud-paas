#--------------------------------------------------
# Expose Gateway Router Information
#--------------------------------------------------

output "evocloud_internet_gateway" {
  value = oci_core_internet_gateway.evocloud_internet_gateway.display_name
}

output "evocloud_internet_gateway_id" {
  value     = oci_core_internet_gateway.evocloud_internet_gateway.id
  sensitive = true
}

output "evocloud_nat_gateway_name" {
  value = oci_core_nat_gateway.evocloud_nat_gateway.display_name
}

output "evocloud_nat_gateway_id" {
  value     = oci_core_nat_gateway.evocloud_nat_gateway.id
  sensitive = true
}