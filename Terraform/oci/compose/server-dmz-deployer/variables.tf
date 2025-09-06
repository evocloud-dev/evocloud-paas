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

variable "OCI_VPC_CIDR" {
  description = "OCI VPC CIDR"
  type        = list(string)
}

variable "OCI_VPC" {
  description = "Main VPC Name"
  type        = string
}

variable "BASE_AMI_NAME" {
  description = "Base Image Name"
  type        = string
}

variable "DEPLOYER_SHORT_HOSTNAME" {
  description = "DEPLOYER Server Short Hostname"
  type        = string
}

variable "BASE_SHAPE_E4_FLEX" {
  description = "Compute Instance Flavor Range"
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

variable "BASE_VOLUME_50" {
  description = "Base Volume Size 50GB"
  type        = string
}

variable "DEPLOYER_BASE_VOLUME_TYPE" {
  description = "DEPLOYER Base Volume Type"
  type        = string
}

variable "public_nsg" {
  description = "Network Security Group ID"
  type        = string
}

variable "dmz_subnet_id" {
  description = "DMZ Subnet ID"
  type        = string
}