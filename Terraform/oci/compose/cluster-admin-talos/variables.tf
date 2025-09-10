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

variable "BASE_AMI_NAME" {
  description = "Base Image Name"
  type        = string
}

variable "TALOS_LB_NODES" {
  description = "Evokube LoadBalancer Nodes"
  type = map(string)
}

variable "TALOS_CTRL_STANDALONE" {
  description = "Talos Standalone Nodes"
  type        = map(string)
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

variable "private_nsg" {
  description = "Network Security Group ID"
  type        = string
}

variable "admin_subnet_id" {
  description = "ADMIN Subnet ID"
  type        = string
}