variable "GCP_REGION" {
  description = "GCP Region"
  type        = string
}

variable "GCP_PROJECT_ID" {
  description = "GCP Project ID"
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

variable "evocode_group_revision" {
  description = "EvoCode Group/Project revision version"
}