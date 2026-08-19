variable "AZ_CLIENT_ID" {
  description = "AZ Client ID"
  type        = string
}

variable "AZ_CLIENT_SECRET" {
  description = "AZ Client Secret"
  type        = string
}

variable "AZ_TENANT_ID" {
  description = "AZ Tenant ID"
  type        = string
}

variable "AZ_SUBSCRIPTION_ID" {
  description = "AZ Subscription ID"
  type        = string
}

variable "CLOUD_USER" {
  description = "Cloud User"
  type        = string
}

variable "CLOUD_PLATFORM" {
  description = "Cloud Platform"
  type        = string
}

variable "PRIVATE_KEY_PAIR" {
  description = "Private Key Pair"
  type        = string
}

variable "deployer_server_eip" {
  description = "Installer Public IP"
  type        = string
}