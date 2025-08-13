#--------------------------------------------------
# IDAM Server VM
#--------------------------------------------------
resource "oci_core_instance" "idam_server" {
  display_name        = var.IDAM_SHORT_HOSTNAME
  availability_domain = var.OCI_AD[0]
  compartment_id      = local.tenancy_ocid
  shape               = var.IDAM_INSTANCE_SIZE


  create_vnic_details {
    nsg_ids    = [var.nsg_id]
    subnet_id  = var.admin_subnet_id
    private_ip = var.IDAM_PRIVATE_IP

  }

  launch_volume_attachments {
    type = "PARAVIRTUALIZED"
    launch_create_volume_details {
      size_in_gbs          = var.BASE_VOLUME_50
      volume_creation_type = "volume"
      display_name         = "base-volume-idam"
    }
  }

  preemptible_instance_config {
    preemption_action {
      preserve_boot_volume = true
      type                 = "TERMINATE"
    }
  }

  source_details {
    source_type = "image"
    instance_source_image_filter_details {
      compartment_id      = local.tenancy_ocid
      defined_tags_filter = {
        namespace = var.ROCKY_IMAGE_NS
        key       = var.ROCKY_IMAGE_KEY
        value     = var.BASE_AMI_NAME
      }
      operating_system         = "Rocky-Linux"
      operating_system_version = var.BASE_AMI_VERSION

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
      ${var.ANSIBLE_DEBUG_FLAG ? "ANSIBLE_DEBUG=1" : ""} ANSIBLE_PIPELINING=True ansible-playbook --timeout 60 /home/${var.CLOUD_USER}/EVOCLOUD/Ansible/server-admin-idam.yml --forks 10 --inventory-file ${oci_core_instance.idam_server.private_ip}, --user ${var.CLOUD_USER} --private-key /etc/pki/tls/gcp-evocloud.pem --vault-password-file /home/${var.CLOUD_USER}/EVOCLOUD/Ansible/secret-vault/ansible-vault-pass.txt --ssh-common-args '-o 'StrictHostKeyChecking=no' -o 'ControlMaster=auto' -o 'ControlPersist=120s'' --extra-vars 'ansible_secret=/home/${var.CLOUD_USER}/EVOCLOUD/Ansible/secret-vault/secret-store.yml server_ip=${oci_core_instance.idam_server.private_ip} idam_short_hostname=${var.IDAM_SHORT_HOSTNAME} domain_tld=${var.DOMAIN_TLD} server_timezone=${var.DEFAULT_TIMEZONE}'
    EOF
    #Ansible logs
    environment = {
      ANSIBLE_LOG_PATH = "/home/${var.CLOUD_USER}/EVOCLOUD/Logs/server-admin-idam-ansible.log"
    }
  }
}
