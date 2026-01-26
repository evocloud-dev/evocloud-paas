#--------------------------------------------------
# EvoCloud Admin Cluster
#--------------------------------------------------
data "hcloud_image" "evok8s" {
  with_selector = "name=evok8s-talos-1-11-5"
  most_recent = true
}

resource "hcloud_firewall" "evok8s_wks_firewall" {
  name = "evok8s-wks-firewall"
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "443"
    source_ips = [
      "0.0.0.0/0"
    ]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "6443"
    source_ips = [
      "0.0.0.0/0"
    ]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "50000-50001"
    source_ips = [
      "0.0.0.0/0"
    ]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "30000-32767"
    source_ips = [
      "0.0.0.0/0"
    ]
  }

  rule {
    direction = "in"
    protocol  = "icmp"
    source_ips = [
      "0.0.0.0/0"
    ]
  }
}

resource "hcloud_server" "talos_ctrlplane" {
  for_each    = var.TALOS_CTRL_NODES
  name        = format("%s", each.value)
  server_type = var.TALOS_CTRL_SIZE     # 2 vCPU, 4GB RAM
  location    = var.HCLOUD_REGION              # Nuremberg
  image       = data.hcloud_image.evok8s.id
  firewall_ids = [hcloud_firewall.evok8s_wks_firewall.id]

  # This gets you an public ipv4 primary ip
  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }

  # Attach to private ipv4 ip
  network {
    network_id = var.admin_subnet_id
    #  ip         = var.DEPLOYER_PRIVATE_IP  # Static IP within subnet range
  }
}