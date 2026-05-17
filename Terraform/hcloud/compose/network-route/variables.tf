variable "GATEWAY_PRIVATE_IP" {
  description = "Private IP Address"
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