variable "HCLOUD_TOKEN" {
  description = "HCLOUD Token"
  type        = string
}

variable "TALOS_CTRL_STANDALONE" {
  description = "Talos Standalone Nodes"
  type        = map(string)
}

variable "TALOS_CTRL_STANDALONE_SIZE" {
  description = "Talos Standalone Controlplane Compute Instance Flavor Size"
  type        = string
  default     = "cx42"
}

variable "HCLOUD_REGION" {
  description = "Server Deployment Region"
  type        = string
}

variable "TALOS_EXTRA_MANIFESTS" {
  description = "Extra Kubernetes Manifest for Talos Machine Configuration"
  type = map(string)
}

variable "dmz_subnet_id" {
  description = "Subnet ID of DMZ Network"
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