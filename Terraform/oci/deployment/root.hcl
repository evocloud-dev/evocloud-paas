#----------------------------------------------------------------------------------------------------
# INPUTS GLOBAL VARIABLES. All variables declare here must use the upper case naming convention
#----------------------------------------------------------------------------------------------------
inputs = {
  ###########################################################################
  # Miscellaneous Variables
  ###########################################################################
  #DOMAIN_TLD     = "evocloud.dev"
  #GCP_METADATA_NS = "169.254.169.254" #Changes depending on zone
  #CLOUD_PLATFORM = "gcp"

  ###########################################################################
  # Common Variables
  ###########################################################################
  #DEFAULT_TIMEZONE = "America/Detroit"
  OCI_PROFILE      = "DEFAULT"
  OCI_PROJECT_ID   = "change me"
  OCI_REGION       = "us-ashburn-1"
  #GCP_REGIONS = ["us-east5-a", "us-east5-b", "us-east5-c"]

  ###########################################################################
  # Network Configurations
  ###########################################################################
  OCI_VPC                    = "evocloud-vpc"
  OCI_VPC_CIDR               = ["10.10.0.0/16"]

  DMZ_SUBNET_CIDR           = "10.10.10.0/24"
  ADMIN_SUBNET_CIDR         = "10.10.20.0/24"
  BACKEND_SUBNET_CIDR       = "10.10.30.0/24"
}