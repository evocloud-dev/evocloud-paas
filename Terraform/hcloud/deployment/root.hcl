#----------------------------------------------------------------------------------------------------
# INPUTS GLOBAL VARIABLES. All variables declare here must use the upper case naming convention
#----------------------------------------------------------------------------------------------------
inputs = {
  ###########################################################################
  # Miscellaneous Variables
  ###########################################################################
  DOMAIN_TLD         = "evocloud.dev"
  HCLOUD_METADATA_NS = "185.12.64.1" #Changes depending on zone
  HCLOUD_METADATA_NS2 = "185.12.64.2" #Changes depending on zone
  CLOUD_PLATFORM     = "hcloud"

  ###########################################################################
  # Common Variables
  ###########################################################################
  DEFAULT_TIMEZONE     = "America/Detroit"
  HCLOUD_PROJECT_ID    = "evocloud-dev"
  HCLOUD_REGION        = "fsn1"
  HCLOUD_REGIONS       = ["nbg1", "fsn1", "hel1"] #Nuremberg region instance types severely limited!
  BASE_AMI_NAME        = "evocloud-rocky8-b0-1-0"
  BASE_VOLUME_SIZE     = "100"
  BASE_VOLUME_10       = "10"
  BASE_VOLUME_20       = "20"
  BASE_VOLUME_50       = "50"
  BASE_VOLUME_200      = "200"
  BASE_VOLUME_250      = "250"
  CLOUD_USER           = "root"
  PUBLIC_KEY_PAIR      = "/etc/pki/tls/hcloud-evonode.pub"
  PRIVATE_KEY_PAIR     = "/etc/pki/tls/hcloud-evonode.pem"
  HCLOUD_TOKEN         = "xxxxxxxx...." #Change it to much your Hetzner Cloud Token

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
  HCLOUD_VPC_CIDR           = "10.10.0.0/16"
  HCLOUD_GATEWAY            = "10.10.0.1"  #IP Address for hcloud gateway. Used on private vm.

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
  DEPLOYER_INSTANCE_SIZE    = "cx33"

  ###########################################################################
  # DMZ Gateway Host
  ###########################################################################
  GATEWAY_SHORT_HOSTNAME    = "evo-gateway"
  GATEWAY_IMG               = "evocloud-rocky8-b0-1-0"
  GATEWAY_PRIVATE_IP        = "10.10.10.6"
  GATEWAY_INSTANCE_SIZE     = "cx23"

  ###########################################################################
  # IDAM Identity and Access Management Server (FreeIPA)
  ###########################################################################
  IDAM_SHORT_HOSTNAME   = "evoidp"
  BASE_IPASERVER_IMG    = "evocloud-rocky8-b0-1-0"
  IDAM_PRIVATE_IP       = "10.10.20.5"
  IDAM_INSTANCE_SIZE    = "cx33"

  ###########################################################################
  # IDAM Identity and Access Management Replica Server
  ###########################################################################
  IDAM_REPLICA_SHORT_HOSTNAME   = "evoidpr"
  IDAM_REPLICA_PRIVATE_IP       = "10.10.20.10"
  IDAM_REPLICA_INSTANCE_SIZE    = "cx33"

  ###########################################################################
  # Remote Desktop Server
  ###########################################################################
  RDP_SHORT_HOSTNAME   = "evodesktop"
  RDP_INSTANCE_SIZE    = "cx33"

  ###########################################################################
  # Virtual Cloud Desktop
  ###########################################################################
  VCD_SHORT_HOSTNAME   = "evovdi"
  VCD_INSTANCE_SIZE    = "cx33"

  ###########################################################################
  # EvoCode Enterprise Code Repository Platform (Gitlab)
  ###########################################################################
  EVOCODE_SHORT_HOSTNAME   = "evocode"
  EVOCODE_INSTANCE_SIZE    = "cx33"

  ###########################################################################
  # EvoCode Runner Code Executor for the EvoCode Platform (Gitlab-Runner)
  ###########################################################################
  EVOCODE_RUNNER_SHORT_HOSTNAME   = "evocode-runner"
  EVOCODE_RUNNER_INSTANCE_SIZE    = "cx33"

  ###########################################################################
  # EvoHarbor Repository Server
  ###########################################################################
  EVOHARBOR_SHORT_HOSTNAME      = "evoharbor"
  EVOHARBOR_INSTANCE_SIZE       = "cx33"

  ###########################################################################
  # STANDALONE Kubernetes Cluster (Kubernetes)
  ###########################################################################
  TALOS_AMI_NAME               = "evok8s-os-1-11-5"
  TALOS_CTRL_STANDALONE_SIZE   = "cx33"
  TALOS_CTRL_STANDALONE        = {
    node01 = "evok8s-workstation"
  }

  #CONTROLPLANE NODES
  TALOS_CTRL_INSTANCE_SIZE    = "cx33"
  TALOS_CTRL_NODES            = {
    node01 = "evok8s-cp01"
    node02 = "evok8s-cp02"
    node03 = "evok8s-cp03"
  }

  #WORKER NODES
  TALOS_WKLD_INSTANCE_SIZE    = "cx43"
  TALOS_WKLD_NODES            = {
    node01 = {
      short_name = "evok8s-wk01"
      extra_volume = true
    }
    node02 = {
      short_name = "evok8s-wk02"
      extra_volume = true
    }
    node03 = {
      short_name = "evok8s-wk03"
      extra_volume = true
    }
    node04 = {
      short_name = "evok8s-wk04"
      extra_volume = true
    }
    node05 = {
      short_name = "evok8s-wk05"
      extra_volume = true
    }
    node06 = {
      short_name = "evok8s-wk06"
      extra_volume = true
    }
  }

  # KUBE API LB NODES
  TALOS_LB_NAME = "evok8s-lb01"

  #INLINE KUBERNETES MANIFESTS
  TALOS_EXTRA_MANIFESTS     = {
    gateway_api_std       = "https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.3.0/standard-install.yaml"
    gateway_api_exp       = "https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.3.0/experimental-install.yaml"
    kubelet_serving_cert  = "https://raw.githubusercontent.com/alex1989hu/kubelet-serving-cert-approver/main/deploy/standalone-install.yaml"
    kube-metric_server    = "https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml"
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
    endpoint                   = "https://<region>.your-objectstorage.com" #https://fsn1.your-objectstorage.com
    access_key                 = "xxxxx"
    secret_key                 = "xxxxx"

    # Required for non-AWS s3
    skip_credentials_validation = true
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