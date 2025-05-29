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

variable "AUTOMATION_FOLDER" {
  description = "Path for the Platform Automation Code"
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

variable "BASE_INSTALLER_IMG" {
  description = "Base Installer Image Name"
  type        = string
}

variable "BASE_VOLUME_SIZE" {
  description = "Base Volume Size in GB"
  type        = string
}

variable "DEPLOYER_SHORT_HOSTNAME" {
  description = "DEPLOYER Server Short Hostname"
  type        = string
}

variable "DEPLOYER_INSTANCE_SIZE" {
  description = "DEPLOYER Compute Instance Flavor Size"
  type        = string
}

variable "DEPLOYER_BASE_VOLUME_TYPE" {
  description = "DEPLOYER Base Volume Type"
  type        = string
}

variable "DEPLOYER_PRIVATE_IP" {
  description = "DEPLOYER Private IPv4"
  type        = string
}

variable "dmz_subnet_name" {
  description = "Output for DMZ Subnet Name"
  type        = string
}

variable "deployer_revision" {
  description = "Deployer revision version"
}

variable "GCP_JSON_CREDS" {
  description = "GCP Secret Json Key File"
  type        = string
}