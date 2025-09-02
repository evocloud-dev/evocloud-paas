#--------------------------------------------------
# Network Security Lists
#--------------------------------------------------
# Add security lists here and attach to subnets
/*resource "oci_core_security_list" "dmz_list" {
  compartment_id = local.tenancy_ocid
  vcn_id         = var.vcn_id
  display_name   =  "dmz_security_list"

  ingress_security_rules {
    protocol    = "6" #TCP
    source      = "0.0.0.0/0"
    stateless   = false
    description = "Allow SSH"
    tcp_options {
      max = 22
      min = 22
    }
  }

  ingress_security_rules {
    protocol    = "6" #TCP
    source      = "0.0.0.0/0"
    stateless   = false
    description = "Allow HTTP"
    tcp_options {
      max = 80
      min = 80
    }
  }

  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    stateless   = false
    description = "Allow HTTPS"
    tcp_options {
      max = 443
      min = 443
    }
  }

  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    stateless   = false
    description = "Allow RDP"
    tcp_options {
      max = 3389
      min = 3389
    }
  }

  ingress_security_rules {
    protocol    = "6" # TCP
    source      = "0.0.0.0/0"
    stateless   = false
    description = "Allow kubectl"
    tcp_options {
      max = 6443
      min = 6443
    }
  }

  ingress_security_rules {
    protocol = "6" # TCP
    source      = "0.0.0.0/0"
    stateless   = false
    description = "Allow talosctl"
    tcp_options {
      max = 50000
      min = 50000
    }
  }

  ingress_security_rules {
    protocol    = "1" #ICMP
    source      = "0.0.0.0/0"
    stateless   = false
    description = "Allow ICMP Ping"
    icmp_options {
      type = 8
      code = 0
    }
  }

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
    description = "Allow all outbound traffic"
  }
}

resource "oci_core_security_list" "private_subnet_list" {
  compartment_id = local.tenancy_ocid
  vcn_id         = var.vcn_id
  display_name   = "private_subnet_security_list"

  ingress_security_rules {
    protocol    = "6" # TCP
    source      = "0.0.0.0/0"
    stateless   = false
    description = "Allow SSH"
    tcp_options {
      max = 22
      min = 22
    }
  }

  ingress_security_rules {
    protocol    = "6" # TCP
    source      = "0.0.0.0/0"
    stateless   = false
    description = "Allow kubectl"
    tcp_options {
      max = 6443
      min = 6443
    }
  }

  ingress_security_rules {
    protocol    = "6" # TCP
    source      = "0.0.0.0/0"
    stateless   = false
    description = "Allow talosctl"
    tcp_options {
      max = 50000
      min = 50000
    }
  }

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
    description = "Allow all outbound traffic"
  }
}*/


#--------------------------------------------------
# Subnets
#--------------------------------------------------
resource "oci_core_subnet" "admin_subnet" {
  #Required
  cidr_block     = var.ADMIN_SUBNET_CIDR
  compartment_id = local.tenancy_ocid
  vcn_id         = var.vcn_id

  #Optional
  display_name               = "admin_subnet"
  prohibit_public_ip_on_vnic = true
  route_table_id             = var.private_rt_table
  #security_list_ids          = [oci_core_security_list.private_subnet_list.id]
}

resource "oci_core_subnet" "backend_subnet" {
  #Required
  cidr_block     = var.BACKEND_SUBNET_CIDR
  compartment_id = local.tenancy_ocid
  vcn_id         = var.vcn_id

  #Optional
  display_name               = "backend_subnet"
  prohibit_public_ip_on_vnic = true
  route_table_id             = var.private_rt_table
  #security_list_ids          = [oci_core_security_list.private_subnet_list.id]
}

resource "oci_core_subnet" "dmz_subnet" {
  #Required
  cidr_block     = var.DMZ_SUBNET_CIDR
  compartment_id = local.tenancy_ocid
  vcn_id         = var.vcn_id

  #Optional
  display_name               = "dmz_subnet"
  prohibit_public_ip_on_vnic = false
  route_table_id             = var.public_rt_table
  #security_list_ids          = [oci_core_security_list.dmz_list.id]
}

