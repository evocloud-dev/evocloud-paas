variable "OCI_PROFILE" {
  description = "OCI Profile"
  type        = string
}

variable "OCI_REGION" {
  description = "OCI Region"
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


