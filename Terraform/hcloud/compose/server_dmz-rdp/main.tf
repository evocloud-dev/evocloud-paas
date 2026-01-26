#--------------------------------------------------
# Server RDP
#--------------------------------------------------
data "hcloud_image" "evovm_snapshot" {
  with_selector = "name=evocloud-rocky-linux-8-b0-1-0"
  most_recent = true
}

data "hcloud_ssh_key" "public_key" {
  name       = "public-ssh-key"
}

resource "hcloud_server" "rdp_server" {
  name        = var.RDP_SHORT_HOSTNAME
  server_type = var.RDP_INSTANCE_SIZE     # 2 vCPU, 4GB RAM
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
#replacing null_resource with terraform_data
#https://developer.hashicorp.com/terraform/language/resources/terraform-data
resource "terraform_data" "trigger_redeploy" {
  input = var.rdp_revision
}

resource "terraform_data" "rdp_server_configuration" {
  depends_on = [hcloud_server.rdp_server]

  #Uncomment below if we want to run Triggers when VM ID changes
  #triggers_replace = [hcloud_server.rdp_server.id]
  #or Uncomment below if we want to run Triggers on Revision number increase
  lifecycle {
    replace_triggered_by = [terraform_data.trigger_redeploy]
  }

  provisioner "local-exec" {
    command = <<EOF
      ${var.ANSIBLE_DEBUG_FLAG ? "ANSIBLE_DEBUG=1" : ""} ANSIBLE_PIPELINING=True ansible-playbook --timeout 60 /home/${var.CLOUD_USER}/EVOCLOUD/Ansible/server-dmz-rdp.yml --forks 10 --inventory-file ${hcloud_server.rdp_server.ipv4_address}, --user ${var.CLOUD_USER} --private-key ${var.PRIVATE_KEY_PAIR} --vault-password-file /home/${var.CLOUD_USER}/EVOCLOUD/Ansible/secret-vault/ansible-vault-pass.txt --ssh-common-args "-o 'StrictHostKeyChecking=no' -o 'ControlMaster=auto' -o 'ControlPersist=120s'" --extra-vars "ansible_secret=/home/${var.CLOUD_USER}/EVOCLOUD/Ansible/secret-vault/secret-store.yml server_ip=${hcloud_server.rdp_server.ipv4_address} idam_server_ip=${var.idam_server_ip} idam_short_hostname=${var.IDAM_SHORT_HOSTNAME} server_short_hostname=${var.RDP_SHORT_HOSTNAME} domain_tld=${var.DOMAIN_TLD} server_timezone=${var.DEFAULT_TIMEZONE} metadata_ns_ip=${var.HCLOUD_METADATA_NS} idam_replica_ip=${var.idam_replica_ip} cloud_platform=${var.CLOUD_PLATFORM}"
    EOF
    #Ansible logs
    environment = {
      ANSIBLE_LOG_PATH = "/home/${var.CLOUD_USER}/EVOCLOUD/Logs/server-dmz-rdp-ansible.log"
    }
  }
}