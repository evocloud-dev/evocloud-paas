variable "GCP_PROJECT_ID" {
  description = "GCP Project ID"
  type        = string
}

variable "GCP_REGION" {
  description = "GCP Region"
  type        = string
}

variable "evotalos_revision" {
  description = "EVOTALOS STANDALONE revision version"
}

variable "deployer_server_eip" {
  description = "Deployer Server Public IP"
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

variable "AUTOMATION_FOLDER" {
  description = "Ansible Code Root Folder"
  type        = string
}

variable "GCP_JSON_CREDS" {
  description = "GCP Secret Json Key File"
  type        = string
}