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

variable "CLOUD_USER" {
  description = "Server Default Login User"
  type        = string
}

variable "NODE_PUBLIC_KEY_PAIR" {
  description = "Public Key Pair for Node SSH Login"
  type        = string
}

variable "NODE_PRIVATE_KEY_PAIR" {
  description = "Private Key Pair for Node SSH Login"
  type        = string
}

variable "ANSIBLE_DEBUG_FLAG" {
  description = "Ansible Debug Flag"
  type        = bool
}

variable "DOMAIN_TLD" {
  description = "Platform Domain Name"
  type        = string
}

variable "DEFAULT_TIMEZONE" {
  description = "Platform Default Timezone"
  type        = string
}

variable "OCI_METADATA_NS" {
  description = "OCI Metadata Nameserver IP"
  type        = string
}

variable "TALOS_AMI_NAME" {
  description = "Talos Base AMI Name"
  type        = string
}

variable "BASE_AMI_NAME" {
  description = "Base Image Name"
  type        = string
}

variable "IDAM_SHORT_HOSTNAME" {
  description = "IDAM Server Short Hostname"
  type        = string
}

variable "TALOS_LB_NODES" {
  description = "Evokube LoadBalancer Nodes"
  type = map(string)
}

variable "TALOS_LB_BASE_VOLUME_TYPE" {
  description = "Talos LoadBalancer Base Volume Type"
  type        = string
}

variable "BASE_VOLUME_50" {
  description = "Base Volume Size 50GB"
  type        = string
}

variable "BASE_SHAPE_E4_FLEX" {
  description = "Compute Instance Flavor Range"
  type        = string
}

variable "TALOS_CTRL_NODES" {
  description = "Talos Controlplane Nodes"
  type = map(string)
}

variable "TALOS_CTRL_BASE_VOLUME_TYPE" {
  description = "Talos Controlplane Base Volume Type"
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

variable "TALOS_WKLD_BASE_VOLUME_TYPE" {
  description = "Talos Workload Base Volume Type"
  type        = string
}

variable "TALOS_EXTRA_MANIFESTS" {
  description = "Extra Kubernetes Manifest for Talos Machine Configuration"
  type = map(string)
}

variable "private_nsg" {
  description = "Network Security Group ID"
  type        = string
}

variable "admin_subnet_id" {
  description = "ADMIN Subnet ID"
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

variable "taloslb_revision" {
  description = "Talos Apiserver loadbalancer revision version"
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
