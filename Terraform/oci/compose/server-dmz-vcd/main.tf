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
# VIRTUAL CLOUD DESKTOP Server VM
#--------------------------------------------------
resource "oci_core_instance" "vcd_server" {
  display_name                            = var.VCD_SHORT_HOSTNAME
  compartment_id                          = var.OCI_TENANCY_ID
  availability_domain                     = data.oci_identity_availability_domains.az_domains.availability_domains[0].name
  shape                                   = var.BASE_SHAPE_E4_FLEX

  shape_config {
    ocpus         = var.VCD_OCPU
    memory_in_gbs = var.VCD_ORAM
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
    boot_volume_vpus_per_gb = var.VCD_BASE_VOLUME_TYPE
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

  provisioner "remote-exec" {
    inline = [ "echo 'EvoNODE Readiness Check Succeeded: Instance is fully up.'" ]
    connection {
      type = "ssh"
      user = var.CLOUD_USER
      timeout = "10"
      private_key = file(var.NODE_PRIVATE_KEY_PAIR)
      host = self.private_ip
    }
  }

  freeform_tags            = {"Platform"= "EvoCloud"}
}

#--------------------------------------------------
# Ansible Configuration Management Code
#--------------------------------------------------
#replacing null_resource with terraform_data
#https://developer.hashicorp.com/terraform/language/resources/terraform-data
resource "terraform_data" "trigger_redeploy" {
  input = var.vcd_revision
}

resource "terraform_data" "vcd_server_configuration" {
  depends_on = [oci_core_instance.vcd_server]

  #Uncomment below if we want to run Triggers when VM ID changes
  #triggers_replace = [google_compute_instance.vcd_server.id]
  #or Uncomment below if we want to run Triggers on Revision number increase
  lifecycle {
    replace_triggered_by = [terraform_data.trigger_redeploy]
  }

  provisioner "local-exec" {
    command = <<EOF
      ${var.ANSIBLE_DEBUG_FLAG ? "ANSIBLE_DEBUG=1" : ""} ANSIBLE_PIPELINING=True ansible-playbook --timeout 60 /home/${var.CLOUD_USER}/EVOCLOUD/Ansible/server-dmz-vcd.yml --forks 10 --inventory-file ${oci_core_instance.vcd_server.private_ip}, --user ${var.CLOUD_USER} --private-key ${var.NODE_PRIVATE_KEY_PAIR} --vault-password-file /home/${var.CLOUD_USER}/EVOCLOUD/Ansible/secret-vault/ansible-vault-pass.txt --ssh-common-args "-o 'StrictHostKeyChecking=no' -o 'ControlMaster=auto' -o 'ControlPersist=120s'" --extra-vars "ansible_secret=/home/${var.CLOUD_USER}/EVOCLOUD/Ansible/secret-vault/secret-store.yml server_ip=${oci_core_instance.vcd_server.private_ip} idam_server_ip=${var.idam_server_ip} idam_short_hostname=${var.IDAM_SHORT_HOSTNAME} server_short_hostname=${var.VCD_SHORT_HOSTNAME} domain_tld=${var.DOMAIN_TLD} server_timezone=${var.DEFAULT_TIMEZONE} metadata_ns_ip=${var.OCI_METADATA_NS} idam_replica_ip=${var.idam_replica_ip} cloud_platform=${var.CLOUD_PLATFORM}, san_ips=["${oci_core_instance.vcd_server.private_ip}", "${oci_core_instance.vcd_server.public_ip}"] ports_list=[80,443]"
    EOF
    #Ansible logs
    environment = {
      ANSIBLE_LOG_PATH = "/home/${var.CLOUD_USER}/EVOCLOUD/Logs/server-dmz-vcd-ansible.log"
    }
  }
}
