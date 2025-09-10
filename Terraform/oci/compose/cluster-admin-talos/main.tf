#--------------------------------------------------
# Data Source to find Custom Talos Image
#--------------------------------------------------
data "oci_core_images" "talos_images" {
  compartment_id = var.OCI_TENANCY_ID
  #Optional
  display_name = var.TALOS_AMI_NAME
}

#--------------------------------------------------
# Data Source to find EvoVM Linux Image
#--------------------------------------------------
data "oci_core_images" "evovm_image" {
  compartment_id  = var.OCI_TENANCY_ID
  #Optional
  display_name    = var.BASE_AMI_NAME
}

##### Availability Domain ######
data "oci_identity_availability_domains" "az_domains" {
  #Required
  compartment_id = var.OCI_TENANCY_ID
}

#--------------------------------------------------
# Loadbalancer VMs
#--------------------------------------------------
# random_integer resource is needed to be able to assign different zones to oci_core_instance
resource "random_integer" "zone_selector_ctrlnode" {
  for_each   = var.TALOS_LB_NODES
  min        = 0
  max        = length(data.oci_identity_availability_domains.az_domains) - 1
}

resource "oci_core_instance" "talos_loadbalancer" {
  for_each                                = var.TALOS_LB_NODES
  compartment_id                          = var.OCI_TENANCY_ID
  display_name                            = format("%s", each.value)
  availability_domain                     = data.oci_identity_availability_domains.az_domains.availability_domains[0].name
  shape                                   = var.BASE_SHAPE_E4_FLEX
  shape_config {
    ocpus         = "2"
    memory_in_gbs = "4"
  }

  create_vnic_details {
    subnet_id        = var.admin_subnet_id
    nsg_ids          = [var.private_nsg]
    assign_public_ip = false
    #hostname_label = format("%s.%s", each.value, var.DOMAIN_TLD)
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.evovm_image.images[0].id
    boot_volume_size_in_gbs = var.BASE_VOLUME_50
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

  freeform_tags               = {"Platform"= "EvoCloud"}
}

#--------------------------------------------------
# Talos Control Plane VMs
#--------------------------------------------------
resource "oci_core_instance" "talos_ctrlplane" {
  for_each                                = var.TALOS_CTRL_NODES
  compartment_id                          = var.OCI_TENANCY_ID
  display_name                            = format("%s", each.value)
  availability_domain                     = data.oci_identity_availability_domains.az_domains.availability_domains[0].name
  shape                                   = var.BASE_SHAPE_E4_FLEX
  shape_config {
    ocpus         = "4"
    memory_in_gbs = "8"
  }

  create_vnic_details {
    subnet_id        = var.admin_subnet_id
    nsg_ids          = [var.private_nsg]
    assign_public_ip = false
    #hostname_label = format("%s.%s", each.value, var.DOMAIN_TLD)
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.talos_images.images[0].id
    boot_volume_size_in_gbs = var.BASE_VOLUME_50
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

  freeform_tags               = {"Platform"= "EvoCloud"}
}

#--------------------------------------------------
#Talos Worker VMs
#--------------------------------------------------
resource "oci_core_instance" "talos_workload" {
  for_each                                = var.TALOS_WKLD_NODES
  compartment_id                          = var.OCI_TENANCY_ID
  display_name                            = format("%s", each.value.short_name)
  availability_domain                     = data.oci_identity_availability_domains.az_domains.availability_domains[0].name
  shape                                   = var.BASE_SHAPE_E4_FLEX
  shape_config {
    ocpus         = "4"
    memory_in_gbs = "8"
  }

  create_vnic_details {
    subnet_id        = var.admin_subnet_id
    nsg_ids          = [var.private_nsg]
    assign_public_ip = false
    #hostname_label = format("%s.%s", each.value, var.DOMAIN_TLD)
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.talos_images.images[0].id
    boot_volume_size_in_gbs = var.BASE_VOLUME_50
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

  freeform_tags               = {"Platform"= "EvoCloud"}
}

##Talos Worker VMs Extra disk creation and attachment
resource "oci_core_volume" "extra_disk" {
  compartment_id                          = var.OCI_TENANCY_ID
  for_each = { for k, v in var.TALOS_WKLD_NODES : k => v if v.extra_volume }

  display_name            = "${oci_core_instance.talos_workload[each.key].display_name}-extra-volume"
  availability_domain     = data.oci_identity_availability_domains.az_domains.availability_domains[0].name
  vpus_per_gb             = var.TALOS_WKLD_BASE_VOLUME_TYPE
  size_in_gbs             = var.BASE_VOLUME_200
  freeform_tags           = {"Platform"= "EvoCloud"}
}

resource "oci_core_volume_attachment" "disk_attachment" {
  for_each = { for k, v in var.TALOS_WKLD_NODES : k => v if v.extra_volume }
  volume_id   = oci_core_volume.extra_disk[each.key].id
  instance_id = oci_core_instance.talos_workload[each.key].id
  attachment_type = "PARAVIRTUALIZED"
}
