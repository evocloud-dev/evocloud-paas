variable "ANSIBLE_DEBUG_FLAG" {
  description = "Ansible Debug Flag"
  type        = string
}

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

variable "DOMAIN_TLD" {
  description = "Platform Domain Name"
  type        = string
}

variable "IDAM_SHORT_HOSTNAME" {
  description = "IDAM Server Short Hostname"
  type        = string
}

variable "PRIVATE_KEY_PAIR" {
  description = "Private SSH Key"
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

variable "TALOS_CTRL_NODES" {
  description = "Talos Controlplane Nodes"
  type = map(string)
}

variable "TALOS_CTRL_INSTANCE_SIZE" {
  description = "Talos Controlplane Compute Instance Flavor Size"
  type        = string
}

variable "TALOS_EXTRA_MANIFESTS" {
  description = "Extra Kubernetes Manifest for Talos Machine Configuration"
  type = map(string)
}

variable "TALOS_LB_NAME" {
  description = "LoadBalancer Server Name"
  type = string
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

variable "admin_subnet_id" {
  description = "Admin Subnet Id"
  type        = string
}

variable "admin_subnet_prefix" {
  description = "CIDR of the admin subnet used to derive the default gateway"
  type        = string
}

variable "cluster_post_config_revision" {
  description = "Cluster Admin Post Configs version"
}

variable "cntrl_plane_sgr" {
  description = "Control Plane Security Group Rule"
  type        = string
}

variable "cluster_name" {
  description = "Talos Kubernetes Cluster Name"
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

variable "kubernetes_version" {
  description = "Kubernetes version to use for the Talos Cluster"
}

variable "rg_location" {
  description = "Resource Group Location"
  type        = string
}

variable "rg_name" {
  description = "Resource Group Name"
  type        = string
}

variable "talos_version" {
  description = "Talos version to use in generating machine configuration"
}

variable "worker_sgr" {
  description = "Worker Node Security Group Rule"
  type        = string
}