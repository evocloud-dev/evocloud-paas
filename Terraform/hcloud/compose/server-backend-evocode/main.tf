#--------------------------------------------------
# Server Evocode
#--------------------------------------------------
data "hcloud_image" "evovm_snapshot" {
  with_selector = "name=evocloud-rocky-linux-8-b0-1-0"
  most_recent = true
}

data "hcloud_ssh_key" "public_key" {
  name       = "public-ssh-key"
}

resource "hcloud_server" "evocode_server" {
  name        = var.EVOCODE_SHORT_HOSTNAME
  server_type = var.EVOCODE_INSTANCE_SIZE         # 2 vCPU, 4GB RAM
  location    = var.HCLOUD_REGION              # Falkenstein
  image       = data.hcloud_image.evovm_snapshot.id
  ssh_keys    = [data.hcloud_ssh_key.public_key.id]

  labels = {
    hostname = "${var.EVOCODE_SHORT_HOSTNAME}.${var.DOMAIN_TLD}"
  }

  # This gets you an ipv4 primary ip
  public_net {
    ipv4_enabled = false
    ipv6_enabled = false
  }

  # Attach to private network
  network {
    network_id = var.backend_subnet_id
  }
}


#--------------------------------------------------
# Ansible Configuration Management Code
#--------------------------------------------------
resource "terraform_data" "redeploy_evocode" {
  input = var.evocode_revision
}

resource "terraform_data" "evocode_server_configuration" {
  depends_on = [hcloud_server.evocode_server]

  #Uncomment below if we want to run Triggers when VM ID changes
  #triggers_replace = [hcloud_server.evocode_server]
  #Uncomment below if we want to run Triggers on Revision number increase
  lifecycle {
    replace_triggered_by = [terraform_data.redeploy_evocode]
  }

  provisioner "local-exec" {
    command = <<EOF
      ${var.ANSIBLE_DEBUG_FLAG ? "ANSIBLE_DEBUG=1" : ""} ANSIBLE_PIPELINING=True ansible-playbook --timeout 60 /home/${var.CLOUD_USER}/EVOCLOUD/Ansible/server-backend-evocode.yml --forks 10 --inventory-file ${one(hcloud_server.evocode_server.network[*].ip)}, --user ${var.CLOUD_USER} --private-key ${var.PRIVATE_KEY_PAIR} --vault-password-file /home/${var.CLOUD_USER}/EVOCLOUD/Ansible/secret-vault/ansible-vault-pass.txt --ssh-common-args "-o 'StrictHostKeyChecking=no' -o 'ControlMaster=auto' -o 'ControlPersist=120s'" --extra-vars "ansible_secret=/home/${var.CLOUD_USER}/EVOCLOUD/Ansible/secret-vault/secret-store.yml server_ip=${one(hcloud_server.evocode_server.network[*].ip)} idam_server_ip=${var.idam_server_ip} idam_replica_ip=${var.idam_replica_ip} idam_short_hostname=${var.IDAM_SHORT_HOSTNAME} server_short_hostname=${var.EVOCODE_SHORT_HOSTNAME} domain_tld=${var.DOMAIN_TLD} server_timezone=${var.DEFAULT_TIMEZONE} cloud_user=${var.CLOUD_USER} metadata_ns_ip=${var.HCLOUD_METADATA_NS} cloud_platform=${var.CLOUD_PLATFORM}"
    EOF
    #Ansible logs
    environment = {
      ANSIBLE_LOG_PATH = "/home/${var.CLOUD_USER}/EVOCLOUD/Logs/server-backend-evocode-ansible.log"
    }
  }
}