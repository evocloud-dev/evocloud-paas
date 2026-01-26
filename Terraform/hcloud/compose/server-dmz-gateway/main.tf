#--------------------------------------------------
# Server DMZ Gateway
#--------------------------------------------------
locals {
  gateway_cloud_init = <<-EOF
    #cloud-config
    packages:
      - iptables
      - iptables-services
    write_files:
      - path: "/etc/NetworkManager/dispatcher.d/ifup-local"
        content: |
          #!/bin/sh

          /bin/echo 1 > /proc/sys/net/ipv4/ip_forward
          /sbin/iptables -t nat -A POSTROUTING -s '${var.HCLOUD_VPC_CIDR}' -o eth0 -j MASQUERADE
        append: true
        permissions: '0755'
    runcmd:
      - reboot
  EOF
}


data "hcloud_image" "evovm_snapshot" {
  with_selector = "name=evocloud-rocky-linux-8-b0-1-0"
  most_recent = true
}

data "hcloud_ssh_key" "public_key" {
  name       = "public-ssh-key"
}

resource "hcloud_server" "gateway_server" {
  name        = var.GATEWAY_SHORT_HOSTNAME
  server_type = var.GATEWAY_INSTANCE_SIZE     # 2 vCPU, 4GB RAM
  location    = var.HCLOUD_REGION              # Nuremberg
  image       = data.hcloud_image.evovm_snapshot.id
  ssh_keys    = [data.hcloud_ssh_key.public_key.id]

  # This gets you an ipv4 primary ip
  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }

  # Attach to private network
  network {
    network_id = var.dmz_subnet_id
    ip         = var.GATEWAY_PRIVATE_IP  # Static IP within subnet range
  }
  user_data = local.gateway_cloud_init
}

#--------------------------------------------------
# Ansible Configuration Management Code
#--------------------------------------------------
resource "terraform_data" "redeploy_gateway" {
  input = var.gateway_revision
}

resource "terraform_data" "gateway_server_configuration" {
  depends_on = [
    hcloud_server.gateway_server
  ]

  lifecycle {
    replace_triggered_by = [terraform_data.redeploy_gateway]
  }

  #Connection to bastion host (Gateway_Server)
  connection {
    host        = hcloud_server.gateway_server.ipv4_address
    type        = "ssh"
    user        = var.CLOUD_USER
    private_key = file(var.PRIVATE_KEY_PAIR)
  }

  provisioner "local-exec" {
    command = <<EOF
      ${var.ANSIBLE_DEBUG_FLAG ? "ANSIBLE_DEBUG=1" : ""} ANSIBLE_PIPELINING=True ansible-playbook --timeout 60 ${var.AUTOMATION_FOLDER}/Ansible/server-dmz-gateway.yml --forks 10 --inventory-file ${hcloud_server.gateway_server.ipv4_address}, --user ${var.CLOUD_USER} --private-key ${var.PRIVATE_KEY_PAIR} --ssh-common-args "-o 'StrictHostKeyChecking=no'"
    EOF
    #Ansible logs
    environment = {
      ANSIBLE_LOG_PATH = "/home/${var.CLOUD_USER}/EVOCLOUD/Logs/gateway_server-ansible.log"
    }
  }
}