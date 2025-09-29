#----------------------------------------------------------------------------------------------------
# INPUTS GLOBAL VARIABLES. All variables declare here must use the upper case naming convention
#----------------------------------------------------------------------------------------------------
inputs = {
  ###########################################################################
  # Miscellaneous Variables
  ###########################################################################
  DOMAIN_TLD      = "evocloud.dev" #+1
  CLOUD_PLATFORM  = "oci"
  OCI_METADATA_NS = "169.254.169.254" #Changes depending on zone

  ###########################################################################
  # Common Variables
  ###########################################################################
  BASE_AMI_NAME           = "evovm-os-8-10" #+1
  BASE_AMI_VERSION        = "8.10"
  BASE_SOURCE             = "Rocky-8-GenericCloud-Base.latest.x86_64.qcow2"
  BASE_VOLUME_50          = "50" #+1
  BASE_VOLUME_200         = "200" #+1
  BASE_SHAPE_E4_FLEX      = "VM.Standard.E4.Flex" #+1
  CLOUD_USER              = "mlkroot" #+1
  DEFAULT_TIMEZONE        = "America/Chicago" #+1
  OCI_PROFILE             = "DEFAULT" #+1
  OCI_REGION              = "us-chicago-1" #+1
  OCI_TENANCY_ID          = "ocid1.tenancy.oc1..aaxxxxxxxxxxxxxxxxxxxxxxxxxxxx" #+1
  TALOS_SOURCE            = "oracle-amd64.raw.xz"
  OCI_PUBLIC_KEY_PAIR     = "/etc/pki/tls/oci_platform.pub" #+1
  OCI_PRIVATE_KEY_PAIR    = "/etc/pki/tls/oci_platform.pem" #+1
  NODE_PUBLIC_KEY_PAIR    = "/etc/pki/tls/evonode.pub" #+1
  NODE_PRIVATE_KEY_PAIR   = "/etc/pki/tls/evonode.pem" #+1
  OCI_CONFIG_CREDS        = "config" #+1

  ###########################################################################
  # Ansible/Automation Runtime Environment Configurations
  ###########################################################################
  ANSIBLE_DEBUG_FLAG  = false #+1
  AUTOMATION_FOLDER   = "/opt/EVOCLOUD" #+1
  AUTOMATION_LOGS     = "/opt/EVOCLOUD/Logs"

  ###########################################################################
  # Network Configurations
  ###########################################################################
  OCI_VPC             = "evocloud-vpc" #+1
  OCI_VPC_CIDR        = ["10.10.0.0/16"] #+1

  ADMIN_SUBNET_CIDR   = "10.10.20.0/24" #+1
  BACKEND_SUBNET_CIDR = "10.10.30.0/24" #+1
  DMZ_SUBNET_CIDR     = "10.10.10.0/24" #+1

  ###########################################################################
  # DMZ Controller Host
  ###########################################################################
  DEPLOYER_SHORT_HOSTNAME   = "evo-master" #+1
  BASE_INSTALLER_IMG        = "evocloud-rocky8-b0-1-0"
  DEPLOYER_PRIVATE_IP       = "10.10.10.5"
  DEPLOYER_BASE_VOLUME_TYPE = "10" # 0: Lower cost | 10: balanced | 20: Higher Performance | 30-120: Ultra High  #+1
  DEPLOYER_OCPU             = "2" # 1 OCPU translates to 2 vCPUs
  DEPLOYER_ORAM             = "4" # size in GB

  ###########################################################################
  # IDAM Identity and Access Management Server (FreeIPA)
  ###########################################################################
  IDAM_SHORT_HOSTNAME   = "evoidp" #+1
  BASE_IPASERVER_IMG    = "evocloud-rocky8-b0-1-0"
  IDAM_PRIVATE_IP       = "10.10.20.5"
  IDAM_BASE_VOLUME_TYPE = "10" # 0: Lower cost | 10: balanced | 20: Higher Performance | 30-120: Ultra High #+1
  IDAM_OCPU             = "1" # 1 OCPU translates to 2 vCPUs
  IDAM_ORAM             = "4" # size in GB

  ###########################################################################
  # IDAM Identity and Access Management Replica Server
  ###########################################################################
  IDAM_REPLICA_SHORT_HOSTNAME   = "evoidpr"
  IDAM_REPLICA_PRIVATE_IP       = "10.10.20.10"
  IDAM_REPLICA_BASE_VOLUME_TYPE = "10" # 0: Lower cost | 10: balanced | 20: Higher Performance | 30-120: Ultra High
  IDAM_REPLICA_OCPU             = "1" # 1 OCPU translates to 2 vCPUs
  IDAM_REPLICA_ORAM             = "4" # size in GB

  ###########################################################################
  # Remote Desktop Server
  ###########################################################################
  RDP_SHORT_HOSTNAME            = "evodesktop"
  RDP_BASE_VOLUME_TYPE          = "10" #0: Lower cost | 10: balanced | 20: Higher Performance | 30-120: Ultra High
  RDP_OCPU                      = "2" # 1 OCPU translates to 2 vCPUs
  RDP_ORAM                      = "8" # size in

  ###########################################################################
  # Virtual Cloud Desktop
  ###########################################################################
  VCD_SHORT_HOSTNAME            = "evodash"
  VCD_BASE_VOLUME_TYPE          = "10" #0: Lower cost | 10: balanced | 20: Higher Performance | 30-120: Ultra High
  VCD_OCPU                      = "2" # 1 OCPU translates to 2 vCPUs
  VCD_ORAM                      = "8" # size in

  ###########################################################################
  # EvoHarbor Repository Server
  ###########################################################################
  EVOHARBOR_SHORT_HOSTNAME      = "evoharbor"
  EVOHARBOR_BASE_VOLUME_TYPE    = "10" #0: Lower cost | 10: balanced | 20: Higher Performance | 30-120: Ultra High
  EVOHARBOR_OCPU                = "2" # 1 OCPU translates to 2 vCPUs
  EVOHARBOR_ORAM                = "8" # size in

  ###########################################################################
  # EvoCode Enterprise Code Repository Management Server
  ###########################################################################
  EVOCODE_SHORT_HOSTNAME        = "evogit"
  EVOCODE_BASE_VOLUME_TYPE      = "10" #0: Lower cost | 10: balanced | 20: Higher Performance | 30-120: Ultra High
  EVOCODE_OCPU                  = "2" # 1 OCPU translates to 2 vCPUs
  EVOCODE_ORAM                  = "8" # size in

  ###########################################################################
  # EvoCode RUNNER Server
  ###########################################################################
  EVOCODE_RUNNER_SHORT_HOSTNAME   = "evogit-runner01"
  EVOCODE_RUNNER_BASE_VOLUME_TYPE = "10" #0: Lower cost | 10: balanced | 20: Higher Performance | 30-120: Ultra High
  EVOCODE_RUNNER_OCPU             = "1" # 1 OCPU translates to 2 vCPUs
  EVOCODE_RUNNER_ORAM             = "4" # size in

  ###########################################################################
  # ADMIN/MANAGEMENT Kubernetes Cluster (Kubernetes)
  ###########################################################################
  #Talos GPU IMG: https://factory.talos.dev/image/86a5d7c9beb23b4aea2777e44ca06c8c2ceea8a874ccd2b9a6743c4f734329e0/v1.11.1/oracle-amd64.raw.xz
  #Talos NON-GPU IMG: https://factory.talos.dev/image/96f8c146a67c80daad900d3fc1a6976fe11062321eee9ab6ae2a6aea88b2d26e/v1.11.1/oracle-amd64.raw.xz
  TALOS_AMI_NAME              = "evocluster-os-1-11-0"#+1

  #CONTROLPLANE NODES
  TALOS_CTRL_BASE_VOLUME_TYPE = "10" # 0: Lower cost | 10: balanced | 20: Higher Performance | 30-120: Ultra High #+1
  TALOS_CTRL_OCPU             = "2" # 1 OCPU translates to 2 vCPUs
  TALOS_CTRL_ORAM             = "4" # size in
  TALOS_CTRL_NODES            = {
    node01 = "evotalos-cp01"
    node02 = "evotalos-cp02"
    node03 = "evotalos-cp03"
  }#+1

  #WORKER NODES
  TALOS_WKLD_BASE_VOLUME_TYPE = "10" # 0: Lower cost | 10: balanced | 20: Higher Performance | 30-120: Ultra High #+1
  TALOS_WKLD_OCPU             = "4" # 1 OCPU translates to 2 vCPUs
  TALOS_WKLD_ORAM             = "8" # size in
  TALOS_WKLD_NODES            = {
    node01 = {
      short_name = "evotalos-wk01"
      extra_volume = true
    }
    node02 = {
      short_name = "evotalos-wk02"
      extra_volume = true
    }
    node03 = {
      short_name = "evotalos-wk03"
      extra_volume = true
    }
    node04 = {
      short_name = "evotalos-wk04"
      extra_volume = true
    }
    node05 = {
      short_name = "evotalos-wk05"
      extra_volume = true
    }
    node06 = {
      short_name = "evotalos-wk06"
      extra_volume = true
    }
  } #+1

  # KUBE API LB NODES
  TALOS_LB_BASE_VOLUME_TYPE = "10" # 0: Lower cost | 10: balanced | 20: Higher Performance | 30-120: Ultra High
  TALOS_LB_OCPU             = "1" # 1 OCPU translates to 2 vCPUs
  TALOS_LB_ORAM             = "2" # size in
  TALOS_LB_NODES            = {
    node01 = "evotalos-lb01"
    node02 = "evotalos-lb02"
  } #+1

  #INLINE KUBERNETES MANIFESTS
  TALOS_EXTRA_MANIFESTS     = {
    gateway_api_std       = "https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.3.0/standard-install.yaml"
    gateway_api_exp       = "https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.3.0/experimental-install.yaml"
    kubelet_serving_cert  = "https://raw.githubusercontent.com/alex1989hu/kubelet-serving-cert-approver/main/deploy/standalone-install.yaml"
    kube-metric_server    = "https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml"
    local-storage_class   = "https://raw.githubusercontent.com/evocloud-dev/evocloud-k8s-manifests/refs/heads/main/local-storageclass.yaml"
    kube-buildpack        = "https://github.com/buildpacks-community/kpack/releases/download/v0.16.1/release-0.16.1.yaml"
  }

  ###########################################################################
  # STANDALONE Kubernetes Cluster (Kubernetes)
  ###########################################################################
  TALOS_STANDALONE_VOLUME_TYPE = "10" # 0: Lower cost | 10: balanced | 20: Higher Performance | 30-120: Ultra High #+1
  TALOS_CTRL_STANDALONE_OCPU   = "4" # 1 OCPU translates to 2 vCPUs
  TALOS_CTRL_STANDALONE_ORAM   = "8" # size in
  TALOS_CTRL_STANDALONE        = {
    node01 = "evotalos-workstation"
  } #+1
} # End inputs

#--------------------------------------------------
# Tfstate Remote State Storage
#--------------------------------------------------
remote_state {
  backend = "oci"
  config     = {
    namespace = "ax1nxxxxxxxxxxxxxx"
    bucket    = "evocloud-tf-state"
    key       = "${basename(get_parent_terragrunt_dir())}/${path_relative_to_include()}"
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
} # End HOOKS
