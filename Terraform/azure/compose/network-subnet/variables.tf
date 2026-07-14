
variable "AZ_PROJECT_ID" {
  description = "AZ Project ID"
  type        = string
}

variable "AZ_STORAGE_ACCT" {
  description = "Storage Account Name"
  type        = string
}

variable "AZ_SUBSCRIPTION_ID" {
  description = "AZ Subscription ID"
  type        = string
}

variable "ADMIN_SUBNET_CIDR" {
  description = "Admin subnet cidr"
  type        = string
}

variable "BACKEND_SUBNET_CIDR" {
  description = "Admin subnet cidr"
  type        = string
}

variable "DMZ_SUBNET_CIDR" {
  description = "Admin subnet cidr"
  type        = string
}

variable "rg_name" {
  description = "Resource Group Name"
  type        = string
}

variable "vnet_name" {
  description = "Virtual Network Name"
  type        = string
}