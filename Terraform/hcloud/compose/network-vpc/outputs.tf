#--------------------------------------------------
# Expose Main VPC ID
#--------------------------------------------------
output "vpc_id" {
  description = "ID of the private network"
  value       = hcloud_network.vpc.id
}

output "vpc_name" {
  description = "ID of the private network"
  value       = nonsensitive(hcloud_network.vpc.name)
}

output "vpc_ip_range" {
  description = "Network VPC IP Range"
  value       = try(hcloud_network.vpc.ip_range, null)
}