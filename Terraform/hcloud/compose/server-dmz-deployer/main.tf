#--------------------------------------------------
# Server DMZ Main
#--------------------------------------------------
data "hcloud_image" "evovm_snapshot" {
  with_selector = "name=evocloud-rocky-linux-8-b0-1-0"
  most_recent = true
}

resource "hcloud_ssh_key" "pub_key" {
  name       = "public-ssh-key"
  public_key = "${file("${var.PUBLIC_KEY_PAIR}")}"
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

#--------------------------------------------------
# Staging Deployment Artifacts
#--------------------------------------------------
resource "terraform_data" "staging_automation_code" {
  depends_on = [hcloud_server.deployer_server]

  connection {
    host        = hcloud_server.deployer_server.ipv4_address
    type        = "ssh"
    user        = var.CLOUD_USER
    private_key = file(var.PRIVATE_KEY_PAIR)
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/${var.CLOUD_USER}/EVOCLOUD"
    ]
  }

  provisioner "file" {
    source        = "/etc/ansible/ansible.cfg"
    destination   = "/tmp/ansible.cfg"
  }

  provisioner "file" {
    source        = var.PRIVATE_KEY_PAIR
    destination   = "/home/${var.CLOUD_USER}/hcloud-evonode.pem"
  }

  provisioner "file" {
    source        = var.PUBLIC_KEY_PAIR
    destination   = "/home/${var.CLOUD_USER}/hcloud-evonode.pub"
  }

  provisioner "file" {
    source        = "${var.AUTOMATION_FOLDER}/evocloud.tar.gz"
    destination   = "/home/${var.CLOUD_USER}/evocloud.tar.gz"
  }

  provisioner "file" {
    source        = "${var.AUTOMATION_FOLDER}/Ansible/secret-vault/ansible-vault-pass.txt"
    destination   = "/home/${var.CLOUD_USER}/ansible-vault-pass.txt"
  }

  provisioner "file" {
    source        = "${var.AUTOMATION_FOLDER}/Ansible/secret-vault/secret-store.yml"
    destination   = "/home/${var.CLOUD_USER}/secret-store.yml"
  }

  provisioner "file" {
    source        = "${var.AUTOMATION_FOLDER}/Terraform/hcloud/deployment/root.hcl"
    destination   = "/home/${var.CLOUD_USER}/root.hcl"
  }

  provisioner "remote-exec" {
    inline = [
      # Unpacks tarball and cleans up
      "tar -xzf /home/${var.CLOUD_USER}/evocloud.tar.gz --strip-components=1 -C /home/${var.CLOUD_USER}/EVOCLOUD",
      "rm -f /home/${var.CLOUD_USER}/evocloud.tar.gz",

      # Moves Nodes key pairs to /etc/pki/tls folder
      # and gives proper ownership and permissions
      "sudo mv /home/${var.CLOUD_USER}/hcloud-evonode.pem /etc/pki/tls",
      "sudo mv /home/${var.CLOUD_USER}/hcloud-evonode.pub /etc/pki/tls",
      "sudo chmod 0600 /etc/pki/tls/hcloud-evonode.pem",
      "sudo chmod 0644 /etc/pki/tls/hcloud-evonode.pub",
      "sudo chown ${var.CLOUD_USER}:${var.CLOUD_USER} /etc/pki/tls/hcloud-evonode.pem",
      "sudo chown ${var.CLOUD_USER}:${var.CLOUD_USER} /etc/pki/tls/hcloud-evonode.pub",

      # Moves Ansible secret-store and vault-pass to Ansible/secret-vault folder
      "mv /home/${var.CLOUD_USER}/secret-store.yml /home/${var.CLOUD_USER}/EVOCLOUD/Ansible/secret-vault/secret-store.yml",
      "mv /home/${var.CLOUD_USER}/ansible-vault-pass.txt /home/${var.CLOUD_USER}/EVOCLOUD/Ansible/secret-vault/ansible-vault-pass.txt",

      # Moves root.hcl into deployment folder
      "mv /home/${var.CLOUD_USER}/root.hcl /home/${var.CLOUD_USER}/EVOCLOUD/Terraform/hcloud/deployment/root.hcl",

      "sudo yum update -y",
      "hostnamectl status"
    ]
  }

}

#--------------------------------------------------
# Ansible Configuration Management Code
#--------------------------------------------------
resource "terraform_data" "redeploy_deployer" {
  input = var.deployer_revision
}

resource "terraform_data" "deployer_server_configuration" {
  depends_on = [
    hcloud_server.deployer_server,
    terraform_data.staging_automation_code
  ]

  lifecycle {
    replace_triggered_by = [terraform_data.redeploy_deployer]
  }

  #Connection to bastion host (DEPLOYER_Server)
  connection {
    host        = var.deployer_server_eip
    type        = "ssh"
    user        = var.CLOUD_USER
    private_key = file(var.PRIVATE_KEY_PAIR)
  }

  provisioner "local-exec" {
    command = <<EOF
      ${var.ANSIBLE_DEBUG_FLAG ? "ANSIBLE_DEBUG=1" : ""} ANSIBLE_PIPELINING=True ansible-playbook --timeout 60 ${var.AUTOMATION_FOLDER}/Ansible/server-dmz-deployer.yml --forks 10 --inventory-file ${hcloud_server.deployer_server.ipv4_address}, --user ${var.CLOUD_USER} --private-key ${var.PRIVATE_KEY_PAIR} --ssh-common-args "-o 'StrictHostKeyChecking=no'"
    EOF
    #Ansible logs
    environment = {
      ANSIBLE_LOG_PATH = "/home/${var.CLOUD_USER}/EVOCLOUD/Logs/deployer_server-ansible.log"
    }
  }
}

