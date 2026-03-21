#--------------------------------------------------
# Expose Subnets Information
#--------------------------------------------------
output "admin_subnet_id" {
  description = "ID of the private admin subnet"
  value       = hcloud_network_subnet.admin_subnet.network_id
  sensitive   = true
}

output "admin_subnet_cidr" {
  description = "Network CIDR for the private admin subnet"
  value       = hcloud_network_subnet.admin_subnet.ip_range
  sensitive   = true
}

output "backend_subnet_id" {
  description = "ID of the private backend subnet"
  value       = hcloud_network_subnet.backend_subnet.network_id
  sensitive   = true
}

output "backend_subnet_cidr" {
  description = "Network CIDR for the private backend subnet"
  value       = hcloud_network_subnet.backend_subnet.ip_range
  sensitive   = true
}

output "dmz_subnet_id" {
  description = "ID of the private dmz subnet"
  value       = hcloud_network_subnet.dmz_subnet.network_id
  sensitive   = true
}

output "dmz_subnet_cidr" {
  description = "Network CIDR for the private dmz subnet"
  value       = hcloud_network_subnet.dmz_subnet.ip_range
  sensitive   = true
}
