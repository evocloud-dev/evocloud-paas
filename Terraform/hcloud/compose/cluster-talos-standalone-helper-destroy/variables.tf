variable "HCLOUD_TOKEN" {
  description = "HCLOUD Token"
  type        = string
  sensitive   = true
}

variable "deployer_server_eip" {
  description = "Deployer Server Public IP"
  type        = string
}

variable "CLOUD_USER" {
  description = "Server Default Login User"
  type        = string
}

variable "PRIVATE_KEY_PAIR" {
  description = "Private Key Pair for SSH Login"
  type        = string
}