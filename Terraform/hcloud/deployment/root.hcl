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
  HCLOUD_REGION        = "nbg1"
  HCLOUD_REGIONS       = ["nbg1", "fsn1", "hel1"]
  BASE_AMI_NAME     = "evocloud-rocky8-b0-1-0"
  BASE_VOLUME_SIZE  = "100"
  BASE_VOLUME_10    = "10"
  BASE_VOLUME_20    = "20"
  BASE_VOLUME_50    = "50"
  BASE_VOLUME_200   = "200"
  BASE_VOLUME_250   = "250"
  CLOUD_USER        = "root"
  PUBLIC_KEY_PAIR   = "/etc/pki/tls/hcloud-evonode.pub"
  PRIVATE_KEY_PAIR  = "/etc/pki/tls/hcloud-evonode.pem"
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
  HCLOUD_NETWORK_ZONE       = "eu-central"
  HCLOUD_VPC                = "evocloud-vpc"
  HCLOUD_VPC_CIDR           = ["10.10.0.0/16"]

  DMZ_SUBNET_CIDR           = "10.10.10.0/24"
  ADMIN_SUBNET_CIDR         = "10.10.20.0/24"
  BACKEND_SUBNET_CIDR       = "10.10.30.0/24"
  #Cilium Loadbalancer LB-IPAM
  ADMIN_SUBNET_CIDR_LBIPAM  = "10.100.250.0/24"

  ###########################################################################
  # DMZ Controller Host
  ###########################################################################
  DEPLOYER_SHORT_HOSTNAME   = "evo-master"
  BASE_INSTALLER_IMG        = "evocloud-rocky8-b0-1-0"
  DEPLOYER_PRIVATE_IP       = "10.10.10.5"
  DEPLOYER_INSTANCE_SIZE    = "cx42"
  DEPLOYER_BASE_VOLUME_TYPE = "pd-balanced" #pd-standard | pd-balanced | pd-ssd | pd-extreme

  ###########################################################################
  # STANDALONE Kubernetes Cluster (Kubernetes)
  ###########################################################################
  TALOS_AMI_NAME               = "evocluster-os-1-11-5"
  TALOS_STANDALONE_VOLUME_TYPE = "pd-balanced" # 0: Lower cost | 10: balanced | 20: Higher Performance | 30-120: Ultra High #+1
  TALOS_CTRL_STANDALONE_SIZE   = "cx42"
  TALOS_CTRL_STANDALONE        = {
    node01 = "evotalos-workstation"
  }

  #INLINE KUBERNETES MANIFESTS
  TALOS_EXTRA_MANIFESTS     = {
    gateway_api_std       = "https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.3.0/standard-install.yaml"
    gateway_api_exp       = "https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.3.0/experimental-install.yaml"
    kubelet_serving_cert  = "https://raw.githubusercontent.com/alex1989hu/kubelet-serving-cert-approver/main/deploy/standalone-install.yaml"
    kube-metric_server    = "https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml"
    local-storage_class   = "https://raw.githubusercontent.com/evocloud-dev/evocloud-k8s-manifests/refs/heads/main/local-storageclass.yaml"
    kube-buildpack        = "https://github.com/buildpacks-community/kpack/releases/download/v0.16.1/release-0.16.1.yaml"
  }

} #End Inputs

#--------------------------------------------------
# Tfstate Remote State Storage
#--------------------------------------------------
remote_state {
  backend = "s3"
  config = {
    region                     = "nbg1" #nbg1 | fsn1 | hel1
    bucket                     = "evocloud-tf-state"
    key                        = "${basename(get_parent_terragrunt_dir())}/${path_relative_to_include()}"
    endpoint                   = "https://<region>.your-objectstorage.com" #https://nbg1.your-objectstore.com
    access_key                 = "xxxxx"
    secret_key                 = "xxxxx"

    # Required for non-AWS s3
    skip_credential_validation = true
    skip_requesting_account_id = true
    skip_region_validation     = true
    skip_metadata_api_check    = true
    skip_s3_checksum           = true
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