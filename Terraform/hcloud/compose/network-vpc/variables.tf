variable "HCLOUD_TOKEN" {
  description = "Hetzner Cloud Project Token"
  type        = string
  sensitive   = true
}

variable "HCLOUD_VPC" {
  description = "Main VPC Name"
  type        = string
}

variable "HCLOUD_VPC_CIDR" {
  description = "HCLOUD_VPC CIDR Range"
  type        = string
}