variable "ANSIBLE_DEBUG_FLAG" {
  description = "Ansible Debug Flag"
  type        = string
}

variable "AUTOMATION_FOLDER" {
  description = "Automation Folder"
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

variable "DEPLOYER_PRIVATE_IP" {
  description = "Installer Private IP Address"
  type        =  string
}

variable "DEPLOYER_SHORT_HOSTNAME" {
  description = "Deployer Short Name"
  type        = string
}

variable "DEPLOYER_INSTANCE_SIZE" {
  description = "Deployer Instance Size"
  type        = string
}

variable "PUBLIC_KEY_PAIR" {
  description = "Public Key Pair"
  type        = string
}

variable "PRIVATE_KEY_PAIR" {
  description = "Private Key Pair"
  type        = string
}

variable "deployer_revision" {
  description = "Installer Version"
  type        = string
}

variable "dmz_subnet_id" {
  description = "DMZ Subnet Id"
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

variable "security_group_rules" {
  description = "Network Security Group Rules"
  type        = string
}