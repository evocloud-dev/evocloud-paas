variable "OCI_REGION" {
  description = "OCI Region"
  type        = string
}

variable "OCI_PROFILE" {
  description = "OCI Default Profile"
  type        = string
}

variable "OCI_TENANCY_ID" {
  description = "OCI Tenancy ID"
  type        = string
}

variable "CLOUD_USER" {
  description = "Server Default Login User"
  type        = string
}

variable "IDAM_SHORT_HOSTNAME" {
  description = "IDAM Server Short Hostname"
  type        = string
}

variable "ANSIBLE_DEBUG_FLAG" {
  description = "Ansible Debug Flag"
  type        = bool
}

variable "DOMAIN_TLD" {
  description = "Platform Domain Name"
  type        = string
}

variable "DEFAULT_TIMEZONE" {
  description = "Platform Default Timezone"
  type        = string
}

variable "CLOUD_PLATFORM" {
  description = "IaaS Infrastructure"
  type        = string
}

variable "OCI_METADATA_NS" {
  description = "OCI Metadata Nameserver IP"
  type        = string
}

variable "BASE_AMI_NAME" {
  description = "Base Image Name"
  type        = string
}

variable "VCD_SHORT_HOSTNAME" {
  description = "Virtual Cloud Desktop Short Hostname"
  type        = string
}

variable "BASE_SHAPE_E4_FLEX" {
  description = "Compute Instance Flavor Range"
  type        = string
}

variable "VCD_OCPU" {
  description = "Total number of CPU cores"
  type        = number

  validation {
    condition = var.VCD_OCPU >= 1 && var.VCD_OCPU <= 64
    error_message = "OCPUs must be between 1 and 64"
  }
}

variable "VCD_ORAM" {
  description = "Total number of RAM Memory in GB"
  type        = number

  validation {
    condition = var.VCD_ORAM >= 1 && var.VCD_ORAM <= 1024
    error_message = "RAM Memory must be between 1 and 1024"
  }
}

variable "NODE_PUBLIC_KEY_PAIR" {
  description = "Public Key Pair for Node SSH Login"
  type        = string
}

variable "NODE_PRIVATE_KEY_PAIR" {
  description = "Private Key Pair for Node SSH Login"
  type        = string
}

variable "BASE_VOLUME_50" {
  description = "Base Volume Size 50GB"
  type        = string
}

variable "VCD_BASE_VOLUME_TYPE" {
  description = "VCD Base Volume Type"
  type        = string
}

variable "public_nsg" {
  description = "Network Security Group ID"
  type        = string
}

variable "dmz_subnet_id" {
  description = "DMZ Subnet ID"
  type        = string
}

variable "idam_server_ip" {
  description = "IDAM Server Private IPv4"
  type        = string
}

variable "idam_replica_ip" {
  description = "IDAM Replica Server Private IPv4"
  type        = string
}

variable "vcd_revision" {
  description = "RDP Server revision version"
}
