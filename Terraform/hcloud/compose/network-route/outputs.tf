#--------------------------------------------------
# Expose Route Information
#--------------------------------------------------

output "network_route_id" {
  description = "Hetzner Network Route ID"
  value     = hcloud_network_route.privNet.id
  sensitive = true
}