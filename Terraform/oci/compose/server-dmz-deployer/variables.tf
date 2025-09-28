variable "OCI_REGION" {
  description = "OCI Region"
  type        = string
}

variable "OCI_PROFILE" {
  description = "OCI Default Profile"
  type        = string
}

variable "OCI_TENANCY_ID" {
  description = "OCI Tenancy ID"
  type        = string
}


variable "BASE_AMI_NAME" {
  description = "Base Image Name"
  type        = string
}

variable "DEPLOYER_SHORT_HOSTNAME" {
  description = "DEPLOYER Server Short Hostname"
  type        = string
}

variable "BASE_SHAPE_E4_FLEX" {
  description = "Compute Instance Flavor Range"
  type        = string
}

variable "DEPLOYER_OCPU" {
  description = "Total number of CPU cores"
  type        = number

  validation {
    condition = var.DEPLOYER_OCPU >= 1 && var.DEPLOYER_OCPU <= 64
    error_message = "OCPUs must be between 1 and 64"
  }
}

variable "DEPLOYER_ORAM" {
  description = "Total number of RAM Memory in GB"
  type        = number

  validation {
    condition = var.DEPLOYER_ORAM >= 1 && var.DEPLOYER_ORAM <= 1024
    error_message = "RAM Memory must be between 1 and 1024"
  }
}

variable "NODE_PUBLIC_KEY_PAIR" {
  description = "Public Key Pair for Node SSH Login"
  type        = string
}

variable "NODE_PRIVATE_KEY_PAIR" {
  description = "Private Key Pair for Node SSH Login"
  type        = string
}

variable "OCI_PRIVATE_KEY_PAIR" {
  description = "OCI Platform Private Key Pair"
  type        = string
}

variable "OCI_PUBLIC_KEY_PAIR" {
  description = "OCI Platform Public Key Pair"
  type        = string
}

variable "AUTOMATION_FOLDER" {
  description = "Path for the Platform Automation Code"
  type        = string
}

variable "OCI_CONFIG_CREDS" {
  description = "OCI Secret Key File"
  type        = string
}

variable "BASE_VOLUME_50" {
  description = "Base Volume Size 50GB"
  type        = string
}

variable "DEPLOYER_BASE_VOLUME_TYPE" {
  description = "DEPLOYER Base Volume Type"
  type        = string
}

variable "DOMAIN_TLD" {
  description = "Platform Domain Name"
  type        = string
}

variable "CLOUD_USER" {
  description = "Server Default Login User"
  type        = string
}

variable "ANSIBLE_DEBUG_FLAG" {
  description = "Ansible Debug Flag"
  type        = bool
}

variable "public_nsg" {
  description = "Network Security Group ID"
  type        = string
}

variable "dmz_subnet_id" {
  description = "DMZ Subnet ID"
  type        = string
}

variable "deployer_revision" {
  description = "Deployer revision version"
}