
variable "AZ_SUBSCRIPTION_ID" {
  description = "AZ Subscription ID"
  type        = string
}

variable "admin_subnet_id" {
  description = "Admin Subnet Id"
  type        = string
}

variable "backend_subnet_id" {
  description = "Backend Subnet Id"
  type        = string
}

variable "dmz_subnet_id" {
  description = "DMZ Subnet Id"
  type        = string
}

variable "rg_location" {
  description = "Resource Group Location"
  type        = string
}

variable "rg_name" {
  description = "Resource Group Name"
  type        = string
}