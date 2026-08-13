variable "AZ_CLIENT_ID" {
  description = "AZ Client ID"
  type        = string
}

variable "AZ_CLIENT_SECRET" {
  description = "AZ Client Secret"
  type        = string
}

variable "AZ_TENANT_ID" {
  description = "AZ Tenant ID"
  type        = string
}

variable "AZ_STORAGE_RG" {
  description = "Azure Storage Resource Group"
  type        = string
}

variable "AZ_SUBSCRIPTION_ID" {
  description = "AZ Subscription ID"
  type        = string
}

variable "CLOUD_USER" {
  description = "Server Default Login User"
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

variable "DOMAIN_TLD" {
  description = "Platform Domain Name"
  type        = string
}

variable "DEFAULT_TIMEZONE" {
  description = "Platform Default Timezone"
  type        = string
}

variable "AUTOMATION_FOLDER" {
  description = "Ansible Code Root Folder"
  type        = string
}

variable "DEPLOYER_SHORT_HOSTNAME" {
  description = "Deployer Server Short Hostname"
  type        = string
}

variable "IDAM_SHORT_HOSTNAME" {
  description = "IDAM Server Short Hostname"
  type        = string
}

variable "deployer_server_eip" {
  description = "Deployer Server Public IP"
  type        = string
}

variable "deployer_private_ip" {
  description = "Deployer Server Private IP"
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

variable "ipaclient_revision" {
  description = "Deployer VM IPAClient Registration revision version"
}