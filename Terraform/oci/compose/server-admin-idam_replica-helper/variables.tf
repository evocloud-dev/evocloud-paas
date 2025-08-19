variable "OCI_PROFILE" {
  description = "GCP Project ID"
  type        = string
}

variable "OCI_REGION" {
  description = "GCP Region"
  type        = string
}

variable "deployer_server_eip" {
  description = "Deployer Server Public IP"
  type        = string
}

variable "CLOUD_USER" {
  description = "Server Default Login User"
  type        = string
}

variable "PRIVATE_NODE_KEY_PAIR" {
  description = "Private Key Pair for SSH Login"
  type        = string
}

