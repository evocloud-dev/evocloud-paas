variable "HCLOUD_TOKEN" {
  description = "HCLOUD Token"
  type        = string
  sensitive   = true
}

variable "TALOS_LB_NAME" {
  description = "LoadBalancer Server Name"
  type = string
}

variable "TALOS_CTRL_NODES" {
  description = "Talos Controlplane Nodes"
  type = map(string)
}

variable "TALOS_CTRL_INSTANCE_SIZE" {
  description = "Talos Controlplane Compute Instance Flavor Size"
  type        = string
}

variable "HCLOUD_REGION" {
  description = "Server Deployment Region"
  type        = string
}

variable "HCLOUD_GATEWAY" {
  description = "HCLOUD Gateway IP for Routing Private VM Traffic"
  type        = string
}

variable "CLOUD_USER" {
  description = "CLOUD USER"
  type        = string
}

variable "TALOS_AMI_NAME" {
  description = "Talos AMI Name"
  type        = string
}

variable "TALOS_WKLD_INSTANCE_SIZE" {
  description = "Talos Workload Compute Instance Flavor Size"
  type        = string
}

variable "TALOS_WKLD_NODES" {
  description = "Talos Worker Nodes"
  type = map(object({
    short_name = string
    extra_volume = bool
  }))
}

variable "BASE_VOLUME_200" {
  description = "Talos Workload Extra Volume 200GB"
  type        = string
}

variable "TALOS_EXTRA_MANIFESTS" {
  description = "Extra Kubernetes Manifest for Talos Machine Configuration"
  type = map(string)
}

variable "HCLOUD_METADATA_NS" {
  description = "HCLOUD Metadata Nameserver IP"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "admin_subnet_id" {
  description = "Output for ADMIN Subnet ID"
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

variable "idam_server_ip" {
  description = "IDAM Server Private IPv4"
  type        = string
}

variable "idam_replica_ip" {
  description = "IDAM Replica Server Private IPv4"
  type        = string
}