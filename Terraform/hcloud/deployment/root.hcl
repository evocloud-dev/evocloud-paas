#----------------------------------------------------------------------------------------------------
# INPUTS GLOBAL VARIABLES. All variables declare here must use the upper case naming convention
#----------------------------------------------------------------------------------------------------
inputs = {
  ###########################################################################
  # Miscellaneous Variables
  ###########################################################################
  DOMAIN_TLD      = "evocloud.dev"
  HCLOUD_METADATA_NS = "169.254.169.254" #Changes depending on zone
  CLOUD_PLATFORM  = "hcloud"

  ###########################################################################
  # Common Variables
  ###########################################################################
  DEFAULT_TIMEZONE  = "America/Detroit"
  HCLOUD_PROJECT_ID    = "evocloud-dev"
  HCLOUD_REGION        = "us-east5"
  HCLOUD_REGIONS       = ["us-east5-a", "us-east5-b", "us-east5-c"]
  BASE_AMI_NAME     = "evocloud-rocky8-b0-1-0"
  BASE_VOLUME_SIZE  = "100"
  BASE_VOLUME_10    = "10"
  BASE_VOLUME_20    = "20"
  BASE_VOLUME_50    = "50"
  BASE_VOLUME_200   = "200"
  BASE_VOLUME_250   = "250"
  CLOUD_USER        = "mlkroot"
  PUBLIC_KEY_PAIR   = "/etc/pki/tls/gcp-evocloud.pub"
  PRIVATE_KEY_PAIR  = "/etc/pki/tls/gcp-evocloud.pem"
  HCLOUD_TOKEN      = "xxxxxxxx...."

  ###########################################################################
  # Ansible/Automation Runtime Environment Configurations
  ###########################################################################
  ANSIBLE_DEBUG_FLAG  = false
  AUTOMATION_FOLDER   = "/opt/EVOCLOUD"
  AUTOMATION_LOGS     = "/opt/EVOCLOUD/Logs"

  ###########################################################################
  # Network Configurations
  ###########################################################################
  HCLOUD_VPC                = "evocloud-vpc"
  HCLOUD_VPC_CIDR           = ["10.10.0.0/16"]

  DMZ_SUBNET_CIDR           = "10.10.0.0/16"
  ADMIN_SUBNET_CIDR         = "10.100.0.0/16"
  BACKEND_SUBNET_CIDR       = "10.200.0.0/16"
  #Cilium Loadbalancer LB-IPAM
  ADMIN_SUBNET_CIDR_LBIPAM  = "10.100.250.0/24"

  ###########################################################################
  # DMZ Controller Host
  ###########################################################################
  DEPLOYER_SHORT_HOSTNAME   = "evo-master"
  BASE_INSTALLER_IMG        = "evocloud-rocky8-b0-1-0"
  DEPLOYER_PRIVATE_IP       = "10.10.10.5"
  DEPLOYER_INSTANCE_SIZE    = "e2-medium"
  DEPLOYER_BASE_VOLUME_TYPE = "pd-balanced" #pd-standard | pd-balanced | pd-ssd | pd-extreme
}

#--------------------------------------------------
# Tfstate Remote State Storage
#--------------------------------------------------
remote_state {
  backend = "s3"
  config = {
    project                    = "evocloud-dev"
    region                     = "nbg1" #nbg1 | fsn1 | hel1
    bucket                     = "evocloud-tf-state"
    key                        = "${basename(get_parent_terragrunt_dir())}/${path_relative_to_include()}"
    endpoint                   = "https://<bucket_name>.<region>.your-objectstorage.com"
    skip_credential_validation = false
    skip_region_validation     = false
    skip_metadata_api_check    = false
  }
}

#----------------------------------------------------------------------------------------------------
# TERRAFORM HOOKS
#----------------------------------------------------------------------------------------------------
terraform {
  before_hook "auto_init" {
    commands = ["validate", "plan", "apply", "destroy", "workspace", "output", "import"]
    execute  = ["terraform", "init"]
  }

  before_hook "before_hook" {
    commands     = ["apply"]
    execute      = ["/usr/bin/date"]
  }

  after_hook "after_hook" {
    commands     = ["apply"]
    execute      = ["/usr/bin/date"]
    run_on_error = false
  }
}