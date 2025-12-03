#--------------------------------------------------
# Server DMZ Main
#--------------------------------------------------
data "hcloud_image" "evovm_snapshot" {
  with_selector = "name=evocloud-rocky-linux-8-b0-1-0"
  most_recent = true
  #name = "evovm-os-8-10"  # Replace with your snapshot name
}

resource "hcloud_ssh_key" "pub_key" {
  name       = "public-ssh-key"
  public_key = "${var.CLOUD_USER}:${file("${var.PUBLIC_KEY_PAIR}")}"
}

resource "hcloud_server" "deployer_server" {
  name        = var.DEPLOYER_SHORT_HOSTNAME
  server_type = var.DEPLOYER_INSTANCE_SIZE     # 2 vCPU, 4GB RAM
  location    = var.HCLOUD_REGION              # Nuremberg
  image       = data.hcloud_image.evovm_snapshot.id
  ssh_keys    = [hcloud_ssh_key.pub_key.id]

  # This gets you an ipv4 primary ip
  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }

  # Attach to private network
  network {
    network_id = var.dmz_subnet_id
    ip         = var.DEPLOYER_PRIVATE_IP  # Static IP within subnet range
  }
}

