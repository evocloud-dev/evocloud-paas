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

variable "evocode_private_ip" {
  description = "EvoCode Server Private IP"
  type        = string
}

variable "fluxcd_git_repo" {
  description = "FluxCD Git Repository Name"
  type        = string
}

variable "fluxcd_repo_group" {
  description = "FluxCD Git Repository Group Name"
  type        = string
}

variable "fluxcd_repo_dir" {
  description = "FluxCD Git Repository Sub-directory"
  type        = string
}

variable "fluxcd_revision" {
  description = "Kubeapp Flux deployment revision version"
}