variable "AUTOMATION_FOLDER" {
  description = "Automation Code Folder"
  type        = string
}

variable "ANSIBLE_DEBUG_FLAG" {
  description = "Ansible Debug Flag"
  type        = string
}

variable "CLOUD_USER" {
  description = "CLOUD USER"
  type        = string
}

variable "DEPLOYER_SHORT_HOSTNAME" {
  description = "Deployer Short Name"
  type        = string
}

variable "DEPLOYER_INSTANCE_SIZE" {
  description = "Instance Size or Shape"
  type        = string
}

variable "DEPLOYER_PRIVATE_IP" {
  description = "Private IP Address"
  type        = string
}

variable "HCLOUD_TOKEN" {
  description = "HCLOUD Auth Token"
  type        = string
}

variable "HCLOUD_REGION" {
  description = "Server Deployment Region"
  type        = string
}

variable "PUBLIC_KEY_PAIR" {
  description = "SSH Key"
  type        = string
}

variable "PRIVATE_KEY_PAIR" {
  description = "Private SSH Key"
  type        = string
}

variable "deployer_revision" {
  description = "Semantic Version"
  type        = string
}

variable "deployer_server_eip" {
  description = "Deployer Server Public IP"
  type        = string
}

variable "dmz_subnet_id" {
  description = "Subnet ID of DMZ Network"
  type        = string
}