variable "ADMIN_SUBNET_CIDR" {
  description = "Admin Subnet CIDR"
  type        = string
}

variable "BACKEND_SUBNET_CIDR" {
  description = "Backend Subnet CIDR"
  type        = string
}

variable "DMZ_SUBNET_CIDR" {
  description = "DMZ Subnet CIDR"
  type        = string
}

variable "HCLOUD_NETWORK_ZONE" {
  description = "Network Zone of VPC"
  type        = string
}

variable "HCLOUD_TOKEN" {
  description = "Hetzner Cloud Project Token"
  type        = string
  sensitive   = true
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}
