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

variable "EVOCODE_INSTANCE_SIZE" {
  description = "EVOCODE Instance Size"
  type        = string
}


variable "EVOCODE_SHORT_HOSTNAME" {
  description = "EVOCODE Short Name"
  type        = string
}

variable "IDAM_SHORT_HOSTNAME" {
  description = "IDAM Short Name"
  type        = string
}

variable "PRIVATE_KEY_PAIR" {
  description = "Private Key Pair"
  type        = string
}

variable "backend_subnet_id" {
  description = "Backend Subnet Id"
  type        = string
}

variable "evocode_revision" {
  description = "EVOCODE Version"
  type        = string
}

variable "idam_server_ip" {
  description = "IDAM Server IP Address"
  type        = string
}

variable "idam_replica_ip" {
  description = "IDAM Server IP Address"
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