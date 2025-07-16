# ocid1.tenancy.oc1..aaaaaaaavgdrbcd2b4gelhigihjv37thwn2cewij6psbzlmouglkycifltuq

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
  OCI_PROJECT_ID   = "ocid1.tenancy.oc1..aaaaaaaavgdrbcd2b4gelhigihjv37thwn2cewij6psbzlmouglkycifltuq"
  OCI_REGION       = "us-ashburn-1"
  #GCP_REGIONS = ["us-east5-a", "us-east5-b", "us-east5-c"]

  ###########################################################################
  # Network Configurations
  ###########################################################################
  OCI_VPC                    = "evocloud-vpc"
  OCI_VPC_CIDR               = ["10.10.0.0/16"]

  #DMZ_SUBNET_CIDR           = "10.10.0.0/16"
  #ADMIN_SUBNET_CIDR         = "10.100.0.0/16"
  #BACKEND_SUBNET_CIDR       = "10.200.0.0/16"

}