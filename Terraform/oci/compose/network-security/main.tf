#--------------------------------------------------
# Network Security Group - Public Facing VMs
#--------------------------------------------------
resource "oci_core_network_security_group" "evocloud_nsg_public" {
  # Required
  compartment_id = var.OCI_TENANCY_ID
  vcn_id         = var.vcn_id
  #Optional
  display_name   = "evocloud-nsg-public"
  freeform_tags   = {"Platform"= "EvoCloud"}
}

#--------------------------------------------------
# Network Security Group Rules - Public Facing VMs
#--------------------------------------------------
resource "oci_core_network_security_group_security_rule" "firewall_rule_ingress_ssh" {
  # Required
  network_security_group_id = oci_core_network_security_group.evocloud_nsg_public.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  description               = "Allow SSH on port 22"
  stateless                 = false

  tcp_options {
    destination_port_range {
      max = 22
      min = 22
    }
  }
}

resource "oci_core_network_security_group_security_rule" "firewall_rule_ingress_http" {
  # Required
  network_security_group_id = oci_core_network_security_group.evocloud_nsg_public.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  description               = "Allow HTTP"
  stateless                 = false

  tcp_options {
    destination_port_range {
      max = 80
      min = 80
    }
  }
}

resource "oci_core_network_security_group_security_rule" "firewall_rule_ingress_https" {
  # Required
  network_security_group_id = oci_core_network_security_group.evocloud_nsg_public.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  description               = "Allow HTTPS"
  stateless                 = false

  tcp_options {
    destination_port_range {
      max = 443
      min = 443
    }
  }
}

resource "oci_core_network_security_group_security_rule" "firewall_rule_ingress_rdp" {
  # Required
  network_security_group_id = oci_core_network_security_group.evocloud_nsg_public.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  description               = "Allow HTTP"
  stateless                 = false

  tcp_options {
    destination_port_range {
      max = 3389
      min = 3389
    }
  }
}

resource "oci_core_network_security_group_security_rule" "firewall_rule_ingress_vnc" {
  # Required
  network_security_group_id = oci_core_network_security_group.evocloud_nsg_public.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  description               = "Allow Kube API"
  stateless                 = false

  tcp_options {
    destination_port_range {
      max = 5950
      min = 5950
    }
  }
}

resource "oci_core_network_security_group_security_rule" "firewall_rule_ingress_talosapid" {
  # Required
  network_security_group_id = oci_core_network_security_group.evocloud_nsg_public.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  description               = "Allow Talos Apid"
  stateless                 = false

  tcp_options {
    destination_port_range {
      max = 50000
      min = 50000
    }
  }
}

resource "oci_core_network_security_group_security_rule" "firewall_rule_ingress_talostrustd" {
  # Required
  network_security_group_id = oci_core_network_security_group.evocloud_nsg_public.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  description               = "Allow Talos Trustd"
  stateless                 = false

  tcp_options {
    destination_port_range {
      max = 50001
      min = 50001
    }
  }
}

resource "oci_core_network_security_group_security_rule" "firewall_rule_ingress_apiserver" {
  # Required
  network_security_group_id = oci_core_network_security_group.evocloud_nsg_public.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  description               = "Allow Kube API"
  stateless                 = false

  tcp_options {
    destination_port_range {
      max = 6443
      min = 6443
    }
  }
}

resource "oci_core_network_security_group_security_rule" "firewall_rule_egress" {
  # Required
  network_security_group_id = oci_core_network_security_group.evocloud_nsg_public.id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
  description               = "Allow outbound traffic"
  stateless                 = false
}


#--------------------------------------------------
# Network Security Group - Private Facing VMs
#--------------------------------------------------
resource "oci_core_network_security_group" "evocloud_nsg_private" {
  # Required
  compartment_id = var.OCI_TENANCY_ID
  vcn_id         = var.vcn_id
  #Optional
  display_name   = "evocloud-nsg-private"
  freeform_tags   = {"Platform"= "EvoCloud"}
}

#--------------------------------------------------
# Network Security Group Rules - Private Facing VMs
#--------------------------------------------------
resource "oci_core_network_security_group_security_rule" "private_rule_ingress" {
  # Required
  network_security_group_id = oci_core_network_security_group.evocloud_nsg_private.id
  direction                 = "INGRESS"
  protocol                  = "all"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  description               = "Allow all internal inbound traffic"
  stateless                 = false
}

resource "oci_core_network_security_group_security_rule" "private_rule_egress" {
  # Required
  network_security_group_id = oci_core_network_security_group.evocloud_nsg_private.id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
  description               = "Allow all internal outbound traffic"
  stateless                 = false
}