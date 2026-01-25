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

variable "EVOCODE_RUNNER_SHORT_HOSTNAME" {
  description = "Evocode Short Name"
  type        = string
}

variable "EVOCODE_RUNNER_INSTANCE_SIZE" {
  description = "Instance Size or Shape"
  type        = string
}

variable "HCLOUD_GATEWAY" {
  description = "HCLOUD Gateway IP for Routing Private VM Traffic"
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
  description = "HCLOUD Auth Token"
  type        = string
}

variable "IDAM_SHORT_HOSTNAME" {
  description = "IDAM Server Short Hostname"
  type        = string
}

variable "PRIVATE_KEY_PAIR" {
  description = "Private SSH Key"
  type        = string
}

variable "backend_subnet_id" {
  description = "Output for ADMIN Subnet ID"
  type        = string
}

variable "evocode_runner_revision" {
  description = "Evocode revision version"
}

variable "idam_server_ip" {
  description = "IDAM Server Private IPv4"
  type        = string
}

variable "idam_replica_ip" {
  description = "IDAM Replica Server Private IPv4"
  type        = string
}

variable "evocode_hostname_fqdn" {
  description = "Evocode Server Hostname"
  type        = string
}