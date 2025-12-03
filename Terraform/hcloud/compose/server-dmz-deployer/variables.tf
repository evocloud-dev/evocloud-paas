
variable "CLOUD_USER" {
  description = "CLOUD USER"
  type        = string
}

variable "DEPLOYER_SHORT_HOSTNAME" {
  description = "Deployer Short Name"
  type        = string
}

variable "DEPLOYER_INSTANCE_SIZE" {
  description = "Instance Size or Shape"
  type        = string
}

variable "DEPLOYER_PRIVATE_IP" {
  description = "Private IP Address"
  type        = string
}

variable "HCLOUD_TOKEN" {
  description = "HCLOUD Auth Token"
  type        = string
}

variable "HCLOUD_REGION" {
  description = "Server Deployment Region"
  type        = string
}

variable "PUBLIC_KEY_PAIR" {
  description = "SSH Key"
  type        = string
}

variable "dmz_subnet_id" {
  description = "Subnet ID of DMZ Network"
  type        = string
}