variable "AZ_STORAGE_RG" {
  description = "AZ Storage Resource Group"
  type        = string
}

variable "AZ_SUBSCRIPTION_ID" {
  description = "AZ Subscription ID"
  type        = string
}

variable "BASE_VOLUME_200" {
  description = "Talos Workload Extra Volume 200GB"
  type        = string
}

variable "CLOUD_USER" {
  description = "Cloud User"
  type        = string
}

variable "PUBLIC_KEY_PAIR" {
  description = "Public Key Pair"
  type        = string
}

variable "TALOS_AMI_NAME" {
  description = "Talos AMI Name"
  type        = string
}

variable "TALOS_CTRL_STANDALONE" {
  description = "Talos Single Node"
  type        = map(string)
}

variable "TALOS_CTRL_STANDALONE_SIZE" {
  description = "Talos Single Node Size"
  type        = string
}

variable "TALOS_EXTRA_MANIFESTS" {
  description = "Extra Kubernetes Manifest for Talos Machine Configuration"
  type = map(string)
}

variable "cntrl_plane_sgr" {
  description = "Control Plane Security Group Rule"
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