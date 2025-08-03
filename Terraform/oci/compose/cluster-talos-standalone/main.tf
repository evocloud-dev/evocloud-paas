
resource "oci_core_image" "talos" {
  compartment_id = local.tenancy_ocid
  display_name   = "evocloud-talos-b010"
  launch_mode    = "PARAVIRTUALIZED"

  image_source_details {
    source_type    = "objectStorageTuple"
    namespace_name = "idusyeyhcv4e" #oci_objectstorage_bucket.images.namespace
    bucket_name    = "vince-oci-bucket" #oci_objectstorage_bucket.images.name
    object_name    = "oracle-amd64.raw.xz" #oci_objectstorage_object.talos[each.key].object

    operating_system         = "Talos"
    #operating_system_version = var.release
    source_image_type        = "QCOW2"
  }

  #lifecycle {
  #  ignore_changes = [
  #    defined_tags,
  #  ]
  #  replace_triggered_by = [oci_objectstorage_object.talos[each.key].content_md5]
  #}
#
  #timeouts {
  #  create = "30m"
  #}
}

#--------------------------------------------------
# Gateway LoadBalancer IP
#--------------------------------------------------
#resource "oci_core_private_ip" "gateway_vip" {
#  display_name    = "${var.cluster_name}-gateway-vip"
#  subnet_id       = var.dmz_subnet_id
#}

#--------------------------------------------------
# Talos Control Plane VMs
#--------------------------------------------------
# random_integer resource is needed to be able to assign different zones to google_compute_instance
resource "random_integer" "zone_selector_ctrlnode" {
  for_each   = var.TALOS_CTRL_STANDALONE
  min        = 0
  max        = length(var.OCI_AD) - 1
}

#resource "oci_core_vlan" "evo-vlan" {
#  display_name     = "evotalos-vlan"
#  compartment_id   = local.tenancy_ocid
#  vcn_id           = var.vpc_id
#  cidr_block       = "10.10.20.0/24"
#  nsg_ids          = [var.nsg_id]
#}

resource "oci_core_instance" "evo-std" {
  for_each            = var.TALOS_CTRL_STANDALONE
  display_name        = format("%s", each.value)
  compartment_id      = local.tenancy_ocid
  availability_domain = element(var.OCI_AD, random_integer.zone_selector_ctrlnode[each.key].result)
  shape               = var.TALOS_CTRL_STANDALONE_SIZE
  preserve_boot_volume                        = false
  preserve_data_volumes_created_at_launch     = false

  create_vnic_details {
    subnet_id      = var.dmz_subnet_id
    nsg_ids        = [var.nsg_id]
    assign_public_ip = false
    #hostname_label = format("%s.%s", each.value, var.DOMAIN_TLD)
  }

  source_details {
    source_type = "image"
    source_id   = oci_core_image.talos.id #var.talos_image_id
    #boot_volume_size_in_gbs = var.BASE_VOLUME_10
  }



  launch_volume_attachments {
    display_name = format("%s-%s", "base-volume", each.value)
    launch_create_volume_details {
      display_name       = format("%s-%s", "base-volume", each.value)
      compartment_id     = local.tenancy_ocid
      size_in_gbs        = var.BASE_VOLUME_50
      volume_creation_type = "ATTRIBUTES"
      vpus_per_gb        = var.TALOS_STANDALONE_VOLUME_TYPE
    }
    type = "paravirtualized"
  }

  #preemptible_instance_config {
  #  preemption_action {
  #    preserve_boot_volume = true
  #    type                 = "TERMINATE"
  #  }
  #}

  #shape_config {
  #  memory_in_gbs = "32"
  #  ocpus         = "4"
  #}
}

#resource "oci_core_vnic_attachment" "evo-vlan-vnic" {
#  for_each = oci_core_instance.evo-std
#  instance_id = each.value.id
#
#  create_vnic_details {
#    vlan_id = oci_core_vlan.evo-vlan.id
#  }
#}