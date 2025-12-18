variable "ANSIBLE_DEBUG_FLAG" {
  description = "Ansible Debug Flag"
  type        = string
}

variable "CLOUD_PLATFORM" {
  description = "IaaS Infrastructure"
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

variable "HCLOUD_METADATA_NS" {
  description = "GCP Metadata Nameserver IP"
  type        = string
}

variable "HCLOUD_REGION" {
  description = "Server Deployment Region"
  type        = string
}

variable "HCLOUD_TOKEN" {
  description = "HCLOUD Token"
  type        = string
}

variable "IDAM_REPLICA_SHORT_HOSTNAME" {
  description = "IDAM Replica Server Short Hostname"
  type        = string
}

variable "IDAM_REPLICA_INSTANCE_SIZE" {
  description = "IDAM Replica Compute Instance Flavor Size"
  type        = string
}

variable "IDAM_REPLICA_PRIVATE_IP" {
  description = "IDAM Replica Private IPv4"
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

variable "admin_subnet_id" {
  description = "Output for ADMIN Subnet ID"
  type        = string
}

variable "idam_replica_revision" {
  description = "IDAM revision version"
}

variable "idam_server_ip" {
  description = "IDAM Server Private IPv4"
  type        = string
}
