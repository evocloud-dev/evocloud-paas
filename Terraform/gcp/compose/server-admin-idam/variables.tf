variable "GCP_REGION" {
  description = "GCP Region"
  type        = string
}

variable "GCP_PROJECT_ID" {
  description = "GCP Project ID"
  type        = string
}

variable "GCP_VPC" {
  description = "Main VPC Name"
  type        = string
}

variable "CLOUD_USER" {
  description = "Server Default Login User"
  type        = string
}

variable "PUBLIC_KEY_PAIR" {
  description = "SSH Server Key Path"
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

variable "AUTOMATION_FOLDER" {
  description = "Ansible Code Root Folder"
  type        = string
}

variable "DOMAIN_TLD" {
  description = "Platform Domain Name"
  type        = string
}

variable "DEFAULT_TIMEZONE" {
  description = "Platform Default Timezone"
  type        = string
}

variable "BASE_IPASERVER_IMG" {
  description = "Base IPAServer Image Name"
  type        = string
}

variable "BASE_VOLUME_SIZE" {
  description = "Base Volume Size in GB"
  type        = string
}

variable "IDAM_SHORT_HOSTNAME" {
  description = "IDAM Server Short Hostname"
  type        = string
}

variable "IDAM_INSTANCE_SIZE" {
  description = "IDAM Compute Instance Flavor Size"
  type        = string
}

variable "IDAM_BASE_VOLUME_TYPE" {
  description = "IDAM Base Volume Type"
  type        = string
}

variable "IDAM_PRIVATE_IP" {
  description = "IDAM Private IPv4"
  type        = string
}

variable "IDAM_REPLICA_PRIVATE_IP" {
  description = "IDAM Replica Private IPv4"
  type        = string
}

variable "admin_subnet_name" {
  description = "Output for ADMIN Subnet Name"
  type        = string
}

variable "deployer_server_eip" {
  description = "Deployer Server Public IP"
  type        = string
}

variable "idam_revision" {
  description = "IDAM revision version"
}