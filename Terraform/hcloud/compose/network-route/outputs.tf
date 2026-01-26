#--------------------------------------------------
# Expose Route Information
#--------------------------------------------------

output "dmz_subnet_id" {
  value     = hcloud_network_route.privNet.id
  sensitive = true
}