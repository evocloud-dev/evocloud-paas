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

#------------------------------------------------------
# EvoCode Enterprise Code Repository Management Server
#------------------------------------------------------
resource "oci_core_instance" "evocode_server" {
  display_name                            = var.EVOCODE_SHORT_HOSTNAME
  compartment_id                          = var.OCI_TENANCY_ID
  availability_domain                     = data.oci_identity_availability_domains.az_domains.availability_domains[2].name
  shape                                   = var.BASE_SHAPE_E4_FLEX
  shape_config {
    ocpus         = "8"
    memory_in_gbs = "16"
  }

  metadata = {
    ssh_authorized_keys = file("${var.NODE_PUBLIC_KEY_PAIR}")
  }
  #metadata_startup_script = "/usr/bin/date"

  create_vnic_details {
    subnet_id        = var.backend_subnet_id
    nsg_ids          = [var.private_nsg]
    assign_public_ip = true
    #hostname_label = format("%s.%s", each.value, var.DOMAIN_TLD)
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.evovm_image.images[0].id
    boot_volume_size_in_gbs = var.BASE_VOLUME_50
    boot_volume_vpus_per_gb = var.EVOCODE_BASE_VOLUME_TYPE
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
# Ansible Configuration Management Code
#--------------------------------------------------
resource "terraform_data" "redeploy_evocode" {
  input = var.evocode_revision
}

resource "terraform_data" "evocode_server_configuration" {
  depends_on = [oci_core_instance.evocode_server]

  #Uncomment below if we want to run Triggers when VM ID changes
  #triggers_replace = [google_compute_instance.evocode_server]
  #Uncomment below if we want to run Triggers on Revision number increase
  lifecycle {
    replace_triggered_by = [terraform_data.redeploy_evocode]
  }

  provisioner "local-exec" {
    command = <<EOF
      ${var.ANSIBLE_DEBUG_FLAG ? "ANSIBLE_DEBUG=1" : ""} ANSIBLE_PIPELINING=True ansible-playbook --timeout 60 /home/${var.CLOUD_USER}/EVOCLOUD/Ansible/server-backend-evocode.yml --forks 10 --inventory-file ${oci_core_instance.evocode_server.private_ip}, --user ${var.CLOUD_USER} --private-key ${var.NODE_PRIVATE_KEY_PAIR} --vault-password-file /home/${var.CLOUD_USER}/EVOCLOUD/Ansible/secret-vault/ansible-vault-pass.txt --ssh-common-args '-o 'StrictHostKeyChecking=no' -o 'ControlMaster=auto' -o 'ControlPersist=120s'' --extra-vars 'ansible_secret=/home/${var.CLOUD_USER}/EVOCLOUD/Ansible/secret-vault/secret-store.yml server_ip=${oci_core_instance.evocode_server.private_ip} idam_server_ip=${var.idam_server_ip} idam_replica_ip=${var.idam_replica_ip} idam_short_hostname=${var.IDAM_SHORT_HOSTNAME} server_short_hostname=${var.EVOCODE_SHORT_HOSTNAME} domain_tld=${var.DOMAIN_TLD} server_timezone=${var.DEFAULT_TIMEZONE} cloud_user=${var.CLOUD_USER} metadata_ns_ip=${var.OCI_METADATA_NS} cloud_platform=${var.CLOUD_PLATFORM}'
    EOF
    #Ansible logs
    environment = {
      ANSIBLE_LOG_PATH = "/home/${var.CLOUD_USER}/EVOCLOUD/Logs/server-backend-evocode-ansible.log"
    }
  }
}
