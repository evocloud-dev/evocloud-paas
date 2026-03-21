variable "ANSIBLE_DEBUG_FLAG" {
  description = "Ansible Debug Flag"
  type        = string
}

variable "CLOUD_USER" {
  description = "CLOUD USER"
  type        = string
}

variable "DEFAULT_TIMEZONE" {
  description = "Platform Default Timezone"
  type        = string
}

variable "DOMAIN_TLD" {
  description = "Platform Domain Name"
  type        = string
}

variable "HCLOUD_GATEWAY" {
  description = "HCLOUD Gateway IP for Routing Private VM Traffic"
  type        = string
}

variable "HCLOUD_REGION" {
  description = "Server Deployment Region"
  type        = string
}

variable "BASE_AMI_NAME" {
  description = "Base Rocky Linux Image Name"
  type        = string
}

variable "HCLOUD_TOKEN" {
  description = "HCLOUD Token"
  type        = string
  sensitive   = true
}

variable "IDAM_INSTANCE_SIZE" {
  description = "IDAM Compute Instance Flavor Size"
  type        = string
}

variable "IDAM_PRIVATE_IP" {
  description = "IDAM Private IPv4"
  type        = string
}

variable "PRIVATE_KEY_PAIR" {
  description = "Private SSH Key"
  type        = string
}

variable "IDAM_SHORT_HOSTNAME" {
  description = "IDAM Server Short Hostname"
  type        = string
}

variable "HCLOUD_METADATA_NS" {
  description = "Hcloud Metadata Nameserver IP"
  type        = string
}

variable "HCLOUD_METADATA_NS2" {
  description = "Hcloud Metadata Second Nameserver IP"
  type        = string
}

variable "admin_subnet_id" {
  description = "Output for ADMIN Subnet ID"
  type        = string
}

variable "idam_revision" {
  description = "IDAM revision version"
}

