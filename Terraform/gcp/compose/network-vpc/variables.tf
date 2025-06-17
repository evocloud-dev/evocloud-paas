variable "GCP_REGION" {
  description = "GCP Region"
  type        = string
}

variable "GCP_PROJECT_ID" {
  description = "GCP Project ID"
  type        = string
}

variable "GCP_VPC" {
  description = "Main VPC Name"
  type        = string
}

variable "DMZ_SUBNET_CIDR" {
  description = "DMZ Subnet CIDR"
  type        = string
}

variable "ADMIN_SUBNET_CIDR" {
  description = "ADMIN Subnet CIDR"
  type        = string
}

variable "BACKEND_SUBNET_CIDR" {
  description = "BACKEND Subnet CIDR"
  type        = string
}

variable "ADMIN_SUBNET_CIDR_LBIPAM" {
  description = "ADMIN Subnet CIDR for Cilium Loadbalancer LB-IPAM"
  type        = string
}

variable "DOMAIN_TLD" {
  description = "Platform Domain Name"
  type        = string
}

variable "IDAM_REPLICA_PRIVATE_IP" {
  description = "IDAM Replica Private IPv4"
  type        = string
}

variable "IDAM_PRIVATE_IP" {
  description = "IDAM Private IPv4"
  type        = string
}