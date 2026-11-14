variable "ANSIBLE_DEBUG_FLAG" {
  description = "Ansible Debug Flag"
  type        = string
}

variable "CLOUD_USER" {
  description = "CLOUD USER"
  type        = string
}

variable "DOMAIN_TLD" {
  description = "Platform Domain Name"
  type        = string
}

variable "HCLOUD_TOKEN" {
  description = "HCLOUD Auth Token"
  type        = string
  sensitive   = true
}

variable "IDAM_SHORT_HOSTNAME" {
  description = "IDAM Server Short Hostname"
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

variable "TALOS_LB_NAME" {
  description = "LoadBalancer Server Name"
  type = string
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
  description = "IDAM Server Private IPv4"
  type        = string
}

variable "kubeapp_configs_revision" {
  description = "Cluster Admin Post Configs version"
}

