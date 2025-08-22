#--------------------------------------------------
# Data Source to find Custom Rocky Linux Images
#--------------------------------------------------

data "oci_core_images" "rocky_images" {
  compartment_id = local.tenancy_ocid

  #Optional
  display_name = var.BASE_AMI_NAME
}

#--------------------------------------------------
# Deployer Server VM
#--------------------------------------------------
resource "oci_core_instance" "deployer_server" {
  display_name                            = var.DEPLOYER_SHORT_HOSTNAME
  compartment_id                          = local.tenancy_ocid
  availability_domain                     = var.OCI_AD[0]
  shape                                   = var.DEPLOYER_INSTANCE_SIZE
  preserve_boot_volume                    = false
  preserve_data_volumes_created_at_launch = false

  metadata = {
    ssh_authorized_keys = file("${var.PUBLIC_NODE_KEY_PAIR}")
  }
  #metadata_startup_script = "/usr/bin/date"

  create_vnic_details {
    subnet_id        = var.dmz_subnet_id
    nsg_ids          = [var.nsg_id]
    assign_public_ip = true
    #hostname_label = format("%s.%s", each.value, var.DOMAIN_TLD)
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.rocky_images.images[0].id
  }

  launch_volume_attachments {
    display_name = "base-volume-deployer"
    type = "paravirtualized"

    launch_create_volume_details {
      display_name         = "base-volume-deployer"
      compartment_id       = local.tenancy_ocid
      size_in_gbs          = var.BASE_VOLUME_50
      volume_creation_type = "ATTRIBUTES"
      vpus_per_gb          = var.DEPLOYER_BASE_VOLUME_TYPE
    }
  }

  preemptible_instance_config {
    preemption_action {
      preserve_boot_volume = true
      type                 = "TERMINATE"
    }
  }
}

#--------------------------------------------------
# Staging Deployment Artifacts
#--------------------------------------------------
resource "terraform_data" "staging_automation_code" {
  depends_on = [oci_core_instance.deployer_server]

  connection {
    host        = oci_core_instance.deployer_server.public_ip
    type        = "ssh"
    user        = var.CLOUD_USER
    private_key = file(var.PRIVATE_NODE_KEY_PAIR)
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
    destination   = "/home/${var.CLOUD_USER}/oci_evocloud.pem"
  }

  provisioner "file" {
    source        = var.PUBLIC_KEY_PAIR
    destination   = "/home/${var.CLOUD_USER}/oci_evocloud.pub"
  }

  provisioner "file" {
    source        = var.PRIVATE_NODE_KEY_PAIR
    destination   = "/home/${var.CLOUD_USER}/oci_evonode.pem"
  }

  provisioner "file" {
    source        = var.PUBLIC_NODE_KEY_PAIR
    destination   = "/home/${var.CLOUD_USER}/oci_evonode.pub"
  }

  provisioner "file" {
    source        = "${var.AUTOMATION_FOLDER}/evocloud.tar.gz"
    destination   = "/home/${var.CLOUD_USER}/evocloud.tar.gz"
  }

  provisioner "file" {
    source        = "${var.AUTOMATION_FOLDER}/Keys/${var.OCI_CONFIG}"
    destination   = "/home/${var.CLOUD_USER}/${var.OCI_CONFIG}"
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
    source        = "${var.AUTOMATION_FOLDER}/Terraform/oci/deployment/root.hcl"
    destination   = "/home/${var.CLOUD_USER}/root.hcl"
  }

  provisioner "remote-exec" {
    inline = [
      # Unpacks tarball and cleans up
      "tar -xzf /home/${var.CLOUD_USER}/evocloud.tar.gz --strip-components=1 -C /home/${var.CLOUD_USER}/EVOCLOUD",
      "rm -f /home/${var.CLOUD_USER}/evocloud.tar.gz",

      # Moves Infrastructure public and private keys to /etc/pki/tls folder
      # and gives proper ownership and permissions
      "sudo mv /home/${var.CLOUD_USER}/oci_evocloud.pem /etc/pki/tls",
      "sudo mv /home/${var.CLOUD_USER}/oci_evocloud.pub /etc/pki/tls",
      "sudo chmod 0600 /etc/pki/tls/oci_evocloud.pem",
      "sudo chmod 0644 /etc/pki/tls/oci_evocloud.pub",
      "sudo chown ${var.CLOUD_USER}:${var.CLOUD_USER} /etc/pki/tls/oci_evocloud.pem",
      "sudo chown ${var.CLOUD_USER}:${var.CLOUD_USER} /etc/pki/tls/oci_evocloud.pub",

      # Moves Node public and private keys to /etc/pki/tls folder
      # and gives proper ownership and permissions
      "sudo mv /home/${var.CLOUD_USER}/oci_evonode.pem /etc/pki/tls",
      "sudo mv /home/${var.CLOUD_USER}/oci_evonode.pub /etc/pki/tls",
      "sudo chmod 0600 /etc/pki/tls/oci_evonode.pem",
      "sudo chmod 0644 /etc/pki/tls/oci_evonode.pub",
      "sudo chown ${var.CLOUD_USER}:${var.CLOUD_USER} /etc/pki/tls/oci_evonode.pem",
      "sudo chown ${var.CLOUD_USER}:${var.CLOUD_USER} /etc/pki/tls/oci_evonode.pub",

      # Moves Ansible secret-store and vault-pass to Ansible/secret-vault folder
      "mv /home/${var.CLOUD_USER}/secret-store.yml /home/${var.CLOUD_USER}/EVOCLOUD/Ansible/secret-vault/secret-store.yml",
      "mv /home/${var.CLOUD_USER}/ansible-vault-pass.txt /home/${var.CLOUD_USER}/EVOCLOUD/Ansible/secret-vault/ansible-vault-pass.txt",

      # Moves OCI Config to .oci folder
      "mkdir -p /home/${var.CLOUD_USER}/.oci",
      "mv /home/${var.CLOUD_USER}/${var.OCI_CONFIG} /home/${var.CLOUD_USER}/.oci/${var.OCI_CONFIG}",

      # Move root.hcl into deployment folder
      "mv /home/${var.CLOUD_USER}/root.hcl /home/${var.CLOUD_USER}/EVOCLOUD/Terraform/oci/deployment/root.hcl",

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
    oci_core_instance.deployer_server,
    terraform_data.staging_automation_code
  ]

  #Uncomment below if we want to run Triggers when VM ID changes
  #triggers_replace = [oci_core_instance.deployer_server]
  #Uncomment below if we want to run Triggers on Revision number increase
  lifecycle {
    replace_triggered_by = [terraform_data.redeploy_deployer]
  }

  provisioner "local-exec" {
    command = <<EOF
      ${var.ANSIBLE_DEBUG_FLAG ? "ANSIBLE_DEBUG=1" : ""} ANSIBLE_PIPELINING=True ansible-playbook --timeout 60 ${var.AUTOMATION_FOLDER}/Ansible/server-dmz-deployer.yml --forks 10 --inventory-file ${oci_core_instance.deployer_server.public_ip}, --user ${var.CLOUD_USER} --private-key ${var.PRIVATE_NODE_KEY_PAIR} --ssh-common-args "-o 'StrictHostKeyChecking=no'"
    EOF
    #Ansible logs
    environment = {
      ANSIBLE_LOG_PATH = "/home/${var.CLOUD_USER}/EVOCLOUD/Logs/deployer_server-ansible.log"
    }
  }
}