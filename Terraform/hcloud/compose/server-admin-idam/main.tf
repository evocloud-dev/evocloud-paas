#--------------------------------------------------
# Server Admin IDAM
#--------------------------------------------------
data "hcloud_image" "evovm_snapshot" {
  with_selector = "name=evocloud-rocky-linux-8-b0-1-0"
  most_recent = true
}

resource "hcloud_ssh_key" "pub_key" {
  name       = "public-ssh-key"
  public_key = "${file("${var.PUBLIC_KEY_PAIR}")}"
}

resource "hcloud_server" "idam_server" {
  name        = var.IDAM_SHORT_HOSTNAME
  server_type = var.IDAM_INSTANCE_SIZE         # 2 vCPU, 4GB RAM
  location    = var.HCLOUD_REGION              # Falkenstein
  image       = data.hcloud_image.evovm_snapshot.id
  ssh_keys    = [hcloud_ssh_key.pub_key.id]

  labels {
    hostname = "${var.IDAM_SHORT_HOSTNAME}.${var.DOMAIN_TLD}"
  }

  # This gets you an ipv4 primary ip
  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }

  # Attach to private network
  network {
    network_id = var.admin_subnet_id
    ip         = var.IDAM_PRIVATE_IP  # Static IP within subnet range
  }

  # This ensures cloud-init completes before considering the resource created
  provisioner "remote-exec" {
    inline = [
      "echo 'Instance is ready'",
    ]
    connection {
      host        = self.ipv4_address
      type        = "ssh"
      user        = var.CLOUD_USER
      private_key = file(var.PRIVATE_KEY_PAIR)
    }
  }
}


#--------------------------------------------------
# Ansible Configuration Management Code
#--------------------------------------------------
resource "terraform_data" "redeploy_idam" {
input = var.idam_revision
}

resource "terraform_data" "idam_server_configuration" {
  depends_on = [hcloud_server.idam_server]

  #Uncomment below if we want to run Triggers when VM ID changes
  #triggers_replace = [hcloud_server.idam_server]
  #Uncomment below if we want to run Triggers on Revision number increase
  lifecycle {
    replace_triggered_by = [terraform_data.redeploy_idam]
  }

  provisioner "local-exec" {
    command = <<EOF
      ${var.ANSIBLE_DEBUG_FLAG ? "ANSIBLE_DEBUG=1" : ""} ANSIBLE_PIPELINING=True ansible-playbook --timeout 60 /home/${var.CLOUD_USER}/EVOCLOUD/Ansible/server-admin-idam.yml --forks 10 --inventory-file ${hcloud_server.idam_server.ipv4_address}, --user ${var.CLOUD_USER} --private-key /etc/pki/tls/hcloud-evonode.pem --vault-password-file /home/${var.CLOUD_USER}/EVOCLOUD/Ansible/secret-vault/ansible-vault-pass.txt --ssh-common-args '-o 'StrictHostKeyChecking=no' -o 'ControlMaster=auto' -o 'ControlPersist=120s'' --extra-vars 'ansible_secret=/home/${var.CLOUD_USER}/EVOCLOUD/Ansible/secret-vault/secret-store.yml server_ip=${hcloud_server.idam_server.ipv4_address} idam_short_hostname=${var.IDAM_SHORT_HOSTNAME} domain_tld=${var.DOMAIN_TLD} server_timezone=${var.DEFAULT_TIMEZONE}'
    EOF
    #Ansible logs
    environment = {
      ANSIBLE_LOG_PATH = "/home/${var.CLOUD_USER}/EVOCLOUD/Logs/server-admin-idam-ansible.log"
    }
  }
}