#--------------------------------------------------
# Internet Gateway for VPC Internet Access
#--------------------------------------------------
resource "oci_core_internet_gateway" "evocloud_inet_gateway" {
  #Required
  compartment_id = local.tenancy_ocid
  vcn_id         = var.vcn_id

  #Optional
  display_name   = "evocloud-inet-gateway"
  enabled        = true
}

#--------------------------------------------------
# NAT Gateway for VPC Subnets Communication
#--------------------------------------------------
resource "oci_core_nat_gateway" "evocloud_nat_gateway" {
  #Required
  compartment_id = local.tenancy_ocid
  vcn_id         = var.vcn_id

  #Optional
  display_name   = "evocloud-nat-gateway"
}

#--------------------------------------------------
# Public Route Table for Internet Gateway
#--------------------------------------------------
resource "oci_core_route_table" "evocloud_public_rt" {
  compartment_id             = local.tenancy_ocid
  vcn_id                     = var.vcn_id
  display_name               = "evocloud-public-rt"

  route_rules {
    network_entity_id = oci_core_internet_gateway.evocloud_inet_gateway.id
    destination       = "0.0.0.0/0"
    #destination_type  = "CIDR_BLOCK"
  }
}

#--------------------------------------------------
# Private Route Table for NAT Gateway
#--------------------------------------------------
resource "oci_core_route_table" "evocloud_private_rt" {
  compartment_id = local.tenancy_ocid
  vcn_id         = var.vcn_id
  display_name   = "evocloud-private-rt"

  route_rules {
    network_entity_id = oci_core_nat_gateway.evocloud_nat_gateway.id
    destination       = "0.0.0.0/0"
    #destination_type  = "CIDR_BLOCK"
  }
}

#--------------------------------------------------
# Network Security Group
#--------------------------------------------------
resource "oci_core_network_security_group" "evocloud_nsg" {
  # Required
  compartment_id = local.tenancy_ocid
  vcn_id         = var.vcn_id
  #Optional
  display_name   = "evocloud-nsg"
}

#--------------------------------------------------
# Network Security Group Rules
#--------------------------------------------------
resource "oci_core_network_security_group_security_rule" "firewall_rule_ingress_ssh" {
  # Required
  network_security_group_id = oci_core_network_security_group.evocloud_nsg.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"

  tcp_options {
    source_port_range {
      max = 22
      min = 22
    }
    destination_port_range {
      max = 22
      min = 22
    }
  }
}

resource "oci_core_network_security_group_security_rule" "firewall_rule_ingress_internal" {
  # Required
  network_security_group_id = oci_core_network_security_group.evocloud_nsg.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"

  tcp_options {
    source_port_range {
      max = 65535
      min = 1
    }
    destination_port_range {
      max = 22
      min = 22
    }
  }
}

resource "oci_core_network_security_group_security_rule" "firewall_rule_ingress_taloskube" {
  # Required
  network_security_group_id = oci_core_network_security_group.evocloud_nsg.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"

  tcp_options {
    source_port_range {
      max = 65535
      min = 1
    }
    destination_port_range {
      max = 6443
      min = 6443
    }
  }
}

resource "oci_core_network_security_group_security_rule" "firewall_rule_ingress_talosctl" {
  # Required
  network_security_group_id = oci_core_network_security_group.evocloud_nsg.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"

  tcp_options {
    source_port_range {
      max = 65535
      min = 1
    }
    destination_port_range {
      max = 50000
      min = 50000
    }
  }
}

resource "oci_core_network_security_group_security_rule" "firewall_rule_egress" {
  # Required
  network_security_group_id = oci_core_network_security_group.evocloud_nsg.id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"

  #tcp_options {
  #  source_port_range {
  #    max = 65535
  #    min = 1
  #  }
  #  destination_port_range {
  #    max = 22
  #    min = 22
  #  }
  #}
}

