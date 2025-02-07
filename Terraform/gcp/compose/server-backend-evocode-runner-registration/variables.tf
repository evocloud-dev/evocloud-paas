variable "GCP_REGION" {
  description = "GCP Region"
  type        = string
}

variable "GCP_PROJECT_ID" {
  description = "GCP Project ID"
  type        = string
}

variable "GCP_METADATA_NS" {
  description = "GCP Metadata Nameserver IP"
  type        = string
}

variable "CLOUD_USER" {
  description = "Server Default Login User"
  type        = string
}

variable "DOMAIN_TLD" {
  description = "Platform Domain Name"
  type        = string
}

variable "AUTOMATION_FOLDER" {
  description = "Ansible Code Root Folder"
  type        = string
}

variable "PRIVATE_KEY_PAIR" {
  description = "Private Key Pair for SSH Login"
  type        = string
}

variable "ANSIBLE_DEBUG_FLAG" {
  description = "Ansible Debug Flag"
  type        = bool
}

variable "idam_server_ip" {
  description = "IDAM Server Private IPv4"
  type        = string
}

variable "idam_replica_ip" {
  description = "IDAM Replica Server Private IPv4"
  type        = string
}

variable "deployer_server_eip" {
  description = "Deployer Server Public IP"
  type        = string
}

variable "evocode_runner_private_ip" {
  description = "EvoCode Runner Private IPv4"
  type        = string
}

variable "evocode_private_ip" {
  description = "EvoCode Server Private IPv4"
  type        = string
}

variable "evocode_runner_hostname_fqdn" {
  description = "EvoCode Server FQDN"
  type        = string
}

variable "runner_registration_revision" {
  description = "Runner Registration revision version"
}