variable "ADMIN_SUBNET_CIDR" {
  description = "ADMIN Subnet CIDR"
  type        = string
}

variable "ANSIBLE_DEBUG_FLAG" {
  description = "Debug flag for Ansible"
  type        = string
}

variable "BASE_AMI_VERSION" {
  description = "Version of Rocky Linux Image"
  type        = string
}

variable "BASE_AMI_NAME" {
  description = "Base image name"
  type        = string
}

variable "BASE_VOLUME_50" {
  description = "Base Volume Size 10GB"
  type        = string
  default     = "50"
}

variable "CLOUD_USER" {
  description = "Cloud User account"
  type        = string
}

variable "DEFAULT_TIMEZONE" {
  description = "Timezone"
  type        = string
}

variable "DOMAIN_TLD" {
  description = "Domain"
  type        = string
}

variable "IDAM_INSTANCE_SIZE" {
  description = "Shape or Flavor of VM Instance"
  type        = string
}

variable "IDAM_PRIVATE_IP" {
  description = "Private IP Address for VNIC"
  type        = string
}

variable "IDAM_SHORT_HOSTNAME" {
  description = "Shortname for host"
  type        = string
}

variable "OCI_VPC" {
  description = "Main VPC Name"
  type        = string
}

variable "OCI_REGION" {
  description = "OCI Region"
  type        = string
}

variable "OCI_PROFILE" {
  description = "OCI Profile"
  type        = string
}

variable "OCI_AD" {
  description = "OCI Availability Domain List"
  type        = list
}

variable "OCI_IMAGE_BUCKET" {
  description = "Bucket for oci images"
  type        = string
}

variable "ROCKY_IMAGE_KEY" {
  description = "Key for Rocky Image tag"
  type        = string
}

variable "ROCKY_IMAGE_NS" {
  description = "Namespace for Rocky Image tag"
  type        = string
}

variable "use_spot" {
  description = "Use Ephemeral VM Instances that can be Terminated"
  type        = bool
}

variable "idam_server_ip" {
  description = "IDAM Server Private IPv4"
  type        = string
  default = "10.10.20.5"
}

variable "idam_replica_ip" {
  description = "IDAM Replica Server Private IPv4"
  type        = string
  default     = "10.10.20.10"
}

variable "idam_revision" {
  description = "Version of IDAM server"
  type        = string
}

variable "admin_subnet_id" {
  description = "Admin Subnet ID"
  type        = string
}

variable "vcn_id" {
  description = "VCN ID"
  type        = string
}

variable "nsg_id" {
  description = "Network Security Group ID"
  type        = string
}


