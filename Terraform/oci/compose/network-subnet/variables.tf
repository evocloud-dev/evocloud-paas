variable "ADMIN_SUBNET_CIDR" {
  description = "ADMIN Subnet CIDR"
  type        = string
}

variable "BACKEND_SUBNET_CIDR" {
  description = "BACKEND Subnet CIDR"
  type        = string
}

variable "DMZ_SUBNET_CIDR" {
  description = "DMZ Subnet CIDR"
  type        = string
}

variable "OCI_VPC" {
  description = "Main VPC Name"
  type        = string
}

variable "OCI_REGION" {
  description = "OCI Region"
  type        = string
}

variable "OCI_PROFILE" {
  description = "OCI Profile"
  type        = string
}

variable "vpc_id" {
  description = "VCN ID"
  type        = string
}

variable "public_rt_table" {
  description = "PUBLIC ROUTE TABLE"
  type        = string
}

variable "private_rt_table" {
  description = "PRIVATE ROUTE TABLE"
  type        = string
}