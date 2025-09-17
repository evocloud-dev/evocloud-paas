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