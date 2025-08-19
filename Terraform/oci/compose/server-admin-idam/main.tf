#--------------------------------------------------
# Data Source to find Custom Rocky Linux Images
#--------------------------------------------------

data "oci_core_images" "rocky_images" {
  compartment_id = local.tenancy_ocid

  #Optional
  display_name = var.BASE_AMI_NAME
}

#--------------------------------------------------
# IDAM Server VM
#--------------------------------------------------
resource "oci_core_instance" "idam_server" {
  display_name        = var.IDAM_SHORT_HOSTNAME
  availability_domain = var.OCI_AD[0]
  compartment_id      = local.tenancy_ocid
  shape               = var.IDAM_INSTANCE_SIZE

  metadata = {
    ssh_authorized_keys = file("${var.PUBLIC_NODE_KEY_PAIR}")
  }

  create_vnic_details {
    nsg_ids    = [var.nsg_id]
    subnet_id  = var.admin_subnet_id
    private_ip = var.IDAM_PRIVATE_IP
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.rocky_images.images[0].id
  }

  launch_volume_attachments {
    display_name = "base-volume-idam"
    launch_create_volume_details {
      display_name         = "base-volume-idam"
      volume_creation_type = "ATTRIBUTES"
      compartment_id       = local.tenancy_ocid
      size_in_gbs          = var.BASE_VOLUME_50
      vpus_per_gb          = var.IDAM_BASE_VOLUME_TYPE
    }
    type = "PARAVIRTUALIZED"
  }

  preemptible_instance_config {
    preemption_action {
      preserve_boot_volume = true
      type                 = "TERMINATE"
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
  depends_on = [oci_core_instance.idam_server]

  #Uncomment below if we want to run Triggers when VM ID changes
  #triggers_replace = [oci_core_instance.idam_server]
  #Uncomment below if we want to run Triggers on Revision number increase
  lifecycle {
    replace_triggered_by = [terraform_data.redeploy_idam]
  }

  provisioner "local-exec" {
    command = <<EOF
      ${var.ANSIBLE_DEBUG_FLAG ? "ANSIBLE_DEBUG=1" : ""} ANSIBLE_PIPELINING=True ansible-playbook --timeout 60 /home/${var.CLOUD_USER}/EVOCLOUD/Ansible/server-admin-idam.yml --forks 10 --inventory-file ${oci_core_instance.idam_server.private_ip}, --user ${var.CLOUD_USER} --private-key ${var.PRIVATE_NODE_KEY_PAIR} --vault-password-file /home/${var.CLOUD_USER}/EVOCLOUD/Ansible/secret-vault/ansible-vault-pass.txt --ssh-common-args '-o 'StrictHostKeyChecking=no' -o 'ControlMaster=auto' -o 'ControlPersist=120s'' --extra-vars 'ansible_secret=/home/${var.CLOUD_USER}/EVOCLOUD/Ansible/secret-vault/secret-store.yml server_ip=${oci_core_instance.idam_server.private_ip} idam_short_hostname=${var.IDAM_SHORT_HOSTNAME} domain_tld=${var.DOMAIN_TLD} server_timezone=${var.DEFAULT_TIMEZONE}'
    EOF
    #Ansible logs
    environment = {
      ANSIBLE_LOG_PATH = "/home/${var.CLOUD_USER}/EVOCLOUD/Logs/server-admin-idam-ansible.log"
    }
  }
}
