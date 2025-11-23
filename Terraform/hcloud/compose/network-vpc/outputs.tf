#--------------------------------------------------
# Expose Main VPC ID
#--------------------------------------------------
output "vpc_id" {
  description = "ID of the private network"
  value       = hcloud_network.vpc.id
}

output "vpc_name" {
  description = "ID of the private network"
  value       = hcloud_network.vpc.name
}