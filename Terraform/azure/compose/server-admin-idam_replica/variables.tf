variable "ANSIBLE_DEBUG_FLAG" {
  description = "Ansible Debug Flag"
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

variable "BASE_INSTALLER_IMG" {
  description = "Base Image Name"
  type        = string
}

variable "CLOUD_USER" {
  description = "Cloud User"
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

variable "IDAM_REPLICA_INSTANCE_SIZE" {
  description = "IDAM Replica Instance Size"
  type        = string
}

variable "IDAM_REPLICA_PRIVATE_IP" {
  description = "IDAM Replica Private IP Address"
  type        =  string
}

variable "IDAM_REPLICA_SHORT_HOSTNAME" {
  description = "IDAM Replica Short Name"
  type        = string
}

variable "PRIVATE_KEY_PAIR" {
  description = "Private Key Pair"
  type        = string
}

variable "PUBLIC_KEY_PAIR" {
  description = "Public Key Pair"
  type        = string
}

variable "admin_subnet_id" {
  description = "ADMIN Subnet Id"
  type        = string
}

variable "idam_replica_revision" {
  description = "IDAM Replica Version"
  type        = string
}

variable "rg_location" {
  description = "Resource Group Location"
  type        = string
}

variable "rg_name" {
  description = "Resource Group Name"
  type        = string
}

variable "ssh_sgr" {
  description = "Network Security Group Rules"
  type        = string
}