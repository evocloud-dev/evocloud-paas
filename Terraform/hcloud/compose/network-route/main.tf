
resource "hcloud_network_route" "privNet" {
  network_id  = var.vpc_id
  destination = "0.0.0.0/0"
  gateway     = var.GATEWAY_PRIVATE_IP
}