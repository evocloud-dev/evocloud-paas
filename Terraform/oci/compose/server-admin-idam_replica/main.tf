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
resource "oci_core_instance" "idam_replica_server" {
  display_name                            = var.IDAM_REPLICA_SHORT_HOSTNAME
  availability_domain                     = var.OCI_AD[0]
  compartment_id                          = local.tenancy_ocid
  shape                                   = var.IDAM_REPLICA_INSTANCE_SIZE
  preserve_boot_volume                    = false
  preserve_data_volumes_created_at_launch = false

  metadata = {
    ssh_authorized_keys = file("${var.PUBLIC_NODE_KEY_PAIR}")
  }

  create_vnic_details {
    nsg_ids    = [var.nsg_id]
    subnet_id  = var.admin_subnet_id
    private_ip = var.IDAM_REPLICA_PRIVATE_IP

  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.rocky_images.images[0].id
  }

  launch_volume_attachments {
    display_name = "base-volume-idam-replica"
    type = "PARAVIRTUALIZED"
    launch_create_volume_details {
      volume_creation_type = "volume"
      display_name         = "base-volume-idam-replica"
      compartment_id       = local.tenancy_ocid
      size_in_gbs          = var.BASE_VOLUME_50
      vpus_per_gb          = var.IDAM_REPLICA_BASE_VOLUME_TYPE
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
# Ansible Configuration Management Code
#--------------------------------------------------
resource "terraform_data" "redeploy_idam" {
  input = var.idam_replica_revision
}

resource "terraform_data" "idam_server_configuration" {
  depends_on = [oci_core_instance.idam_replica_server]

  #Uncomment below if we want to run Triggers when VM ID changes
  #triggers_replace = [oci_core_instance.idam_server]
  #Uncomment below if we want to run Triggers on Revision number increase
  lifecycle {
    replace_triggered_by = [terraform_data.redeploy_idam]
  }

  provisioner "local-exec" {
    command = <<EOF
      ${var.ANSIBLE_DEBUG_FLAG ? "ANSIBLE_DEBUG=1" : ""} ANSIBLE_PIPELINING=True ansible-playbook --timeout 60 /home/${var.CLOUD_USER}/EVOCLOUD/Ansible/server-admin-idam-replica.yml --forks 10 --inventory-file ${oci_core_instance.idam_replica_server.private_ip}, --user ${var.CLOUD_USER} --private-key ${var.PRIVATE_NODE_KEY_PAIR} --vault-password-file /home/${var.CLOUD_USER}/EVOCLOUD/Ansible/secret-vault/ansible-vault-pass.txt --ssh-common-args '-o 'StrictHostKeyChecking=no' -o 'ControlMaster=auto' -o 'ControlPersist=120s'' --extra-vars 'ansible_secret=/home/${var.CLOUD_USER}/EVOCLOUD/Ansible/secret-vault/secret-store.yml server_ip=${oci_core_instance.idam_replica_server.private_ip} idam_server_ip=${var.idam_server_ip} idam_replica_ip=${oci_core_instance.idam_replica_server.private_ip} idam_short_hostname=${var.IDAM_SHORT_HOSTNAME} server_short_hostname=${var.IDAM_REPLICA_SHORT_HOSTNAME} idam_replica_short_hostname=${var.IDAM_REPLICA_SHORT_HOSTNAME} domain_tld=${var.DOMAIN_TLD} server_timezone=${var.DEFAULT_TIMEZONE} cloud_platform=${var.CLOUD_PLATFORM}'
    EOF
    #Ansible logs
    environment = {
      ANSIBLE_LOG_PATH = "/home/${var.CLOUD_USER}/EVOCLOUD/Logs/server-admin-idam-ansible.log"
    }
  }
}
