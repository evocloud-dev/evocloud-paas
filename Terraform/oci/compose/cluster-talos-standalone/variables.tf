variable "OCI_REGION" {
  description = "OCI Region"
  type        = string
}

variable "OCI_PROFILE" {
  description = "OCI Default Profile"
  type        = string
}

variable "OCI_TENANCY_ID" {
  description = "OCI Tenancy ID"
  type        = string
}

variable "TALOS_AMI_NAME" {
  description = "Talos Base AMI Name"
  type        = string
}

variable "TALOS_CTRL_STANDALONE" {
  description = "Talos Standalone Nodes"
  type        = map(string)
}

variable "TALOS_STANDALONE_VOLUME_TYPE" {
  description = "Talos VM Base Volume Type"
  type        = string
  default     = "pd-balanced"
}

variable "TALOS_CTRL_STANDALONE_OCPU" {
  description = "Total number of CPU cores"
  type        = number

  validation {
    condition = var.TALOS_CTRL_STANDALONE_OCPU >= 1 && var.TALOS_CTRL_STANDALONE_OCPU <= 64
    error_message = "OCPUs must be between 1 and 64"
  }
}

variable "TALOS_CTRL_STANDALONE_ORAM" {
  description = "Total number of RAM Memory in GB"
  type        = number

  validation {
    condition = var.TALOS_CTRL_STANDALONE_ORAM >= 1 && var.TALOS_CTRL_STANDALONE_ORAM <= 1024
    error_message = "RAM Memory must be between 1 and 1024"
  }
}

variable "BASE_VOLUME_50" {
  description = "Base Volume Size 50GB"
  type        = string
}

variable "BASE_SHAPE_E4_FLEX" {
  description = "Compute Instance Flavor Range"
  type        = string
}

variable "TALOS_EXTRA_MANIFESTS" {
  description = "Extra Kubernetes Manifest for Talos Machine Configuration"
  type = map(string)
}

variable "dmz_subnet_id" {
  description = "Output for DMZ Subnet ID"
  type        = string
}

variable "public_nsg" {
  description = "Output for Public Network Security Group"
  type        = string
}

variable "cluster_name" {
  description = "Talos Kubernetes Cluster Name"
  type        = string
}

variable "talos_version" {
  description = "Talos version to use in generating machine configuration"
}

variable "kubernetes_version" {
  description = "Kubernetes version to use for the Talos Cluster"
}