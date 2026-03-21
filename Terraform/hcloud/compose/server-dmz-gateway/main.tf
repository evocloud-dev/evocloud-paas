#--------------------------------------------------
# Server DMZ Gateway
#--------------------------------------------------
locals {
  gateway_cloud_init = <<-EOF
    #cloud-config
    package_update: true

    packages:
      - iptables
      - iptables-services

    write_files:
      - path: /etc/NetworkManager/dispatcher.d/ifup-local
        content: |
          #!/bin/sh
          /bin/echo 1 > /proc/sys/net/ipv4/ip_forward
          /sbin/iptables -t nat -A POSTROUTING -s '${var.HCLOUD_VPC_CIDR}' -o eth0 -j MASQUERADE
        permissions: '0755'

    runcmd:
      - reboot
  EOF
}

data "hcloud_ssh_key" "public_key" {
  name       = "public-ssh-key"
}

resource "hcloud_server" "gateway_server" {
  name        = var.GATEWAY_SHORT_HOSTNAME
  server_type = var.GATEWAY_INSTANCE_SIZE     # 2 vCPU, 4GB RAM
  location    = var.HCLOUD_REGION              # Nuremberg
  image       = var.BASE_AMI_NAME
  ssh_keys    = [data.hcloud_ssh_key.public_key.id]

  # Attach to private network
  network {
    network_id = var.dmz_subnet_id
    ip         = var.GATEWAY_PRIVATE_IP  # Static IP within subnet range
    #There is a bug with Terraform 1.4+ which causes the network to be detached & attached on every apply. Set alias_ips = []
    alias_ips = [] #Bug: https://github.com/hetznercloud/terraform-provider-hcloud/issues/650#issuecomment-1497160625
  }

  # Attach Public ipv4 ip
  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }

  #COME BACK HERE AND SET A FIREWALL RULE
  #firewall_ids = each.value.SECURITY_GROUP_IDS

  user_data = local.gateway_cloud_init

  labels = {
    Platform = "EvoCloud"
  }
}