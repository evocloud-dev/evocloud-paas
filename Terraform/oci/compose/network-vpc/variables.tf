variable "OCI_VPC_CIDR" {
  description = "OCI VPC CIDR"
  type        = list(string)
}

variable "OCI_PROJECT_ID" {
  description = "OCI Project ID"
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