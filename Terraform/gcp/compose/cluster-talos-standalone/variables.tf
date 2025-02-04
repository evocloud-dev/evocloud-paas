variable "GCP_REGION" {
  description = "GCP Region"
  type        = string
}

variable "GCP_REGIONS" {
  description = "List of GCP High Availability Regions to use"
  type        = list(string)
}

variable "GCP_PROJECT_ID" {
  description = "GCP Project ID"
  type        = string
}

variable "CLOUD_USER" {
  description = "Server Default Login User"
  type        = string
}

variable "DOMAIN_TLD" {
  description = "Platform Domain Name"
  type        = string
}

variable "TALOS_AMI_NAME" {
  description = "Talos Base AMI Name"
  type        = string
}

variable "TALOS_AMI_SOURCE" {
  description = "Link to the Talos OS Raw Disk"
  type        = string
}

variable "BASE_VOLUME_10" {
  description = "Base Volume Size 10GB"
  type        = string
}

variable "TALOS_CTRL_STANDALONE_SIZE" {
  description = "Talos Standalone Controlplane Compute Instance Flavor Size"
  type        = string
}


variable "TALOS_STANDALONE_VOLUME_TYPE" {
  description = "Talos VM Base Volume Type"
  type        = string
}

variable "TALOS_CTRL_STANDALONE" {
  description = "Talos Standalone Controlplane Nodes"
  type = map(string)
}

variable "TALOS_EXTRA_MANIFESTS" {
  description = "Extra Kubernetes Manifest for Talos Machine Configuration"
  type = map(string)
}

variable "GCP_METADATA_NS" {
  description = "GCP Metadata Nameserver IP"
  type        = string
}

variable "dmz_subnet_name" {
  description = "Output for DMZ Subnet Name"
  type        = string
}


variable "idam_server_ip" {
  description = "IDAM Server Private IPv4"
  type        = string
}

variable "idam_replica_ip" {
  description = "IDAM Replica Server Private IPv4"
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

variable "create_talos_img" {
  description = "Boolean variable to determine whether to create the Talos Base Image"
  type        = bool
  default     = false
}