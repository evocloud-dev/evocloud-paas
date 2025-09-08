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
# IDAM REPLICA Server VM
#--------------------------------------------------
resource "oci_core_instance" "idam_replica_server" {
  display_name                            = var.IDAM_REPLICA_SHORT_HOSTNAME
  compartment_id                          = var.OCI_TENANCY_ID
  availability_domain                     = data.oci_identity_availability_domains.az_domains.availability_domains[1].name
  shape                                   = var.BASE_SHAPE_E4_FLEX
  shape_config {
    ocpus         = "4"
    memory_in_gbs = "8"
  }

  metadata = {
    ssh_authorized_keys = file("${var.NODE_PUBLIC_KEY_PAIR}")
  }
  #metadata_startup_script = "/usr/bin/date"

  create_vnic_details {
    subnet_id        = var.admin_subnet_id
    nsg_ids          = [var.private_nsg]
    assign_public_ip = true
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.evovm_image.images[0].id
    boot_volume_size_in_gbs = var.BASE_VOLUME_50
    boot_volume_vpus_per_gb = var.IDAM_REPLICA_BASE_VOLUME_TYPE
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