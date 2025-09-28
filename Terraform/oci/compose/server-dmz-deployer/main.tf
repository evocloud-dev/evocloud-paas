#--------------------------------------------------
# Data Source to find EvoVM Linux Image
#--------------------------------------------------
data "oci_core_images" "evovm_image" {
  compartment_id  = var.OCI_TENANCY_ID
  #Optional
  display_name    = var.BASE_AMI_NAME
}

data "oci_identity_availability_domains" "az_domains" {
  #Required
  compartment_id = var.OCI_TENANCY_ID
}

#--------------------------------------------------
# Deployer Server VM
#--------------------------------------------------
resource "oci_core_instance" "deployer_server" {
  display_name                            = var.DEPLOYER_SHORT_HOSTNAME
  compartment_id                          = var.OCI_TENANCY_ID
  availability_domain                     = data.oci_identity_availability_domains.az_domains.availability_domains[0].name
  shape                                   = var.BASE_SHAPE_E4_FLEX

  shape_config {
    ocpus         = var.DEPLOYER_OCPU
    memory_in_gbs = var.DEPLOYER_ORAM
  }

  metadata = {
    ssh_authorized_keys = file("${var.NODE_PUBLIC_KEY_PAIR}")
  }
  #metadata_startup_script = "/usr/bin/date"

  create_vnic_details {
    subnet_id        = var.dmz_subnet_id
    nsg_ids          = [var.public_nsg]
    assign_public_ip = true
    #hostname_label = format("%s.%s", each.value, var.DOMAIN_TLD)
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.evovm_image.images[0].id
    boot_volume_size_in_gbs = var.BASE_VOLUME_50
    boot_volume_vpus_per_gb = var.DEPLOYER_BASE_VOLUME_TYPE
  }

  agent_config {
    are_all_plugins_disabled = true
    is_management_disabled   = true
    is_monitoring_disabled   = true
  }

  availability_config {
    is_live_migration_preferred = true
    recovery_action             = "RESTORE_INSTANCE"
  }

  launch_options {
    boot_volume_type        = "PARAVIRTUALIZED"
    remote_data_volume_type = "PARAVIRTUALIZED"
    network_type            = "PARAVIRTUALIZED"
  }

  instance_options {
    are_legacy_imds_endpoints_disabled = true
  }

  freeform_tags            = {"Platform"= "EvoCloud"}
}

#--------------------------------------------------
# Policy for delegating permissions to deployer vm
#--------------------------------------------------
#resource "oci_identity_dynamic_group" "sa_automation" {
#  name           = "sa_automation"
#  compartment_id = var.OCI_TENANCY_ID
#  description    = "Delegates automation privileges to deployer vm"
#  matching_rule = "ANY {instance.id = '${oci_core_instance.deployer_server.id}'}"
#}

#resource "oci_identity_policy" "sa_automation_policy" {
#  name           = "sa_automation_policy"
#  compartment_id = var.OCI_TENANCY_ID
#  description    = "Assigns required permissions"
#  statements = [
#    "Allow dynamic-group ${oci_identity_dynamic_group.sa_automation.name} to manage all-resources in compartment ${var.OCI_TENANCY_ID}"
#  ]
#}

#--------------------------------------------------
# Staging Deployment Artifacts
#--------------------------------------------------
resource "terraform_data" "staging_automation_code" {
  depends_on = [oci_core_instance.deployer_server]

  connection {
    host        = oci_core_instance.deployer_server.public_ip
    type        = "ssh"
    user        = var.CLOUD_USER
    private_key = file(var.NODE_PRIVATE_KEY_PAIR)
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
    source        = var.OCI_PRIVATE_KEY_PAIR
    destination   = "/home/${var.CLOUD_USER}/oci_platform.pem"
  }

  provisioner "file" {
    source        = var.OCI_PUBLIC_KEY_PAIR
    destination   = "/home/${var.CLOUD_USER}/oci_platform.pub"
  }

  provisioner "file" {
    source        = var.NODE_PRIVATE_KEY_PAIR
    destination   = "/home/${var.CLOUD_USER}/evonode.pem"
  }

  provisioner "file" {
    source        = var.NODE_PUBLIC_KEY_PAIR
    destination   = "/home/${var.CLOUD_USER}/evonode.pub"
  }

  provisioner "file" {
    source        = "${var.AUTOMATION_FOLDER}/evocloud.tar.gz"
    destination   = "/home/${var.CLOUD_USER}/evocloud.tar.gz"
  }

  provisioner "file" {
    source        = "${var.AUTOMATION_FOLDER}/Keys/${var.OCI_CONFIG_CREDS}"
    destination   = "/home/${var.CLOUD_USER}/${var.OCI_CONFIG_CREDS}"
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

      # Moves Nodes key pairs to /etc/pki/tls folder
      # and gives proper ownership and permissions
      "sudo mv /home/${var.CLOUD_USER}/evonode.pem /etc/pki/tls",
      "sudo mv /home/${var.CLOUD_USER}/evonode.pub /etc/pki/tls",
      "sudo chmod 0600 /etc/pki/tls/evonode.pem",
      "sudo chmod 0644 /etc/pki/tls/evonode.pub",
      "sudo chown ${var.CLOUD_USER}:${var.CLOUD_USER} /etc/pki/tls/evonode.pem",
      "sudo chown ${var.CLOUD_USER}:${var.CLOUD_USER} /etc/pki/tls/evonode.pub",

      # Moves OCI Platform keys pairs to /etc/pki/tls folder
      # and gives proper ownership and permissions
      "sudo mv /home/${var.CLOUD_USER}/oci_platform.pem /etc/pki/tls",
      "sudo mv /home/${var.CLOUD_USER}/oci_platform.pub /etc/pki/tls",
      "sudo chmod 0600 /etc/pki/tls/oci_platform.pem",
      "sudo chmod 0644 /etc/pki/tls/oci_platform.pub",
      "sudo chown ${var.CLOUD_USER}:${var.CLOUD_USER} /etc/pki/tls/oci_platform.pem",
      "sudo chown ${var.CLOUD_USER}:${var.CLOUD_USER} /etc/pki/tls/oci_platform.pub",

      # Moves Ansible secret-store and vault-pass to Ansible/secret-vault folder
      "mv /home/${var.CLOUD_USER}/secret-store.yml /home/${var.CLOUD_USER}/EVOCLOUD/Ansible/secret-vault/secret-store.yml",
      "mv /home/${var.CLOUD_USER}/ansible-vault-pass.txt /home/${var.CLOUD_USER}/EVOCLOUD/Ansible/secret-vault/ansible-vault-pass.txt",

      # Moves root.hcl into deployment folder
      "mv /home/${var.CLOUD_USER}/root.hcl /home/${var.CLOUD_USER}/EVOCLOUD/Terraform/oci/deployment/root.hcl",

      # Moves OCI Config file
      "mkdir /home/${var.CLOUD_USER}/.oci",
      "mv /home/${var.CLOUD_USER}/config /home/${var.CLOUD_USER}/.oci",

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
      ${var.ANSIBLE_DEBUG_FLAG ? "ANSIBLE_DEBUG=1" : ""} ANSIBLE_PIPELINING=True ansible-playbook --timeout 60 ${var.AUTOMATION_FOLDER}/Ansible/server-dmz-deployer.yml --forks 10 --inventory-file ${oci_core_instance.deployer_server.public_ip}, --user ${var.CLOUD_USER} --private-key ${var.NODE_PRIVATE_KEY_PAIR} --ssh-common-args "-o 'StrictHostKeyChecking=no'"
    EOF
    #Ansible logs
    environment = {
      ANSIBLE_LOG_PATH = "/home/${var.CLOUD_USER}/EVOCLOUD/Logs/deployer_server-ansible.log"
    }
  }
}