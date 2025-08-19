variable "BASE_AMI_NAME" {
  description = "Base Image Name"
  type        = string
}

variable "BASE_VOLUME_50" {
  description = "Base Volume Size 50GB"
  type        = string
  default     = "50"
}

variable "OCI_AD" {
  description = "OCI Availability Domain"
  type        = list(string)
}

variable "OCI_CONFIG" {
  description = "File For Accessing OCI Environment"
  type        = string
}

variable "OCI_REGION" {
  description = "OCI Region"
  type        = string
}

variable "OCI_PROFILE" {
  description = "OCI PROFILE"
  type        = string
}

variable "CLOUD_USER" {
  description = "Server Default Login User"
  type        = string
}

variable "PUBLIC_KEY_PAIR" {
  description = "SSH Server Key Path"
  type        = string
}

variable "PRIVATE_KEY_PAIR" {
  description = "Private Key Pair for SSH Login"
  type        = string
}

variable "PUBLIC_NODE_KEY_PAIR" {
  description = "Public Key Pair for Node SSH Login"
  type        = string
}

variable "PRIVATE_NODE_KEY_PAIR" {
  description = "Private Key Pair for Node SSH Login"
  type        = string
}

variable "AUTOMATION_FOLDER" {
  description = "Path for the Platform Automation Code"
  type        = string
}

variable "ANSIBLE_DEBUG_FLAG" {
  description = "Ansible Debug Flag"
  type        = bool
}

variable "DOMAIN_TLD" {
  description = "Platform Domain Name"
  type        = string
}

variable "DEPLOYER_SHORT_HOSTNAME" {
  description = "DEPLOYER Server Short Hostname"
  type        = string
}

variable "DEPLOYER_INSTANCE_SIZE" {
  description = "DEPLOYER Compute Instance Flavor Size"
  type        = string
}

variable "DEPLOYER_BASE_VOLUME_TYPE" {
  description = "DEPLOYER Base Volume Type"
  type        = string
}

variable "use_spot" {
  description = "Use Ephemeral VM Instances that can be Terminated"
  type        = bool
}

variable "dmz_subnet_name" {
  description = "DMZ Subnet Name"
  type        = string
}

variable "dmz_subnet_id" {
  description = "DMZ Subnet ID"
  type        = string
}

variable "deployer_revision" {
  description = "Deployer revision version"
}

variable "nsg_id" {
  description = "Network Security Group ID"
  type        = string
}
