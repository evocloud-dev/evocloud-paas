#----------------------------------------------------------------------------------------------------
# INPUTS GLOBAL VARIABLES. All variables declare here must use the upper case naming convention
#----------------------------------------------------------------------------------------------------
inputs = {
  ###########################################################################
  # Miscellaneous Variables
  ###########################################################################
  DOMAIN_TLD     = "evocloud.dev"
  CLOUD_PLATFORM = "oci"

  ###########################################################################
  # Common Variables
  ###########################################################################
  BASE_AMI_NAME          = "evovm-os-8-10" #+1
  BASE_AMI_VERSION       = "8.10"
  BASE_SOURCE            = "Rocky-8-GenericCloud-Base.latest.x86_64.qcow2"
  BASE_VOLUME_50         = "50" #+1
  BASE_SHAPE_E4_FLEX     = "VM.Standard.E4.Flex" #+1
  CLOUD_USER             = "mlkroot"
  DEFAULT_TIMEZONE       = "America/Chicago"
  OCI_PROFILE            = "DEFAULT" #+1
  OCI_REGION             = "us-chicago-1" #+1
  OCI_TENANCY_ID         = "ocid1.tenancy.oc1..axxxxxxxxxxxxxxxxx" #+1
  OCI_PUBLIC_KEY_PAIR    = "/etc/pki/tls/oci_platform.pub"
  OCI_PRIVATE_KEY_PAIR   = "/etc/pki/tls/oci_platform.pem"
  NODE_PUBLIC_KEY_PAIR   = "/etc/pki/tls/evonode.pub" #+1
  NODE_PRIVATE_KEY_PAIR  = "/etc/pki/tls/evonode.pem" #+1
  TALOS_SOURCE           = "oracle-amd64.raw.xz"

  ###########################################################################
  # Ansible/Automation Runtime Environment Configurations
  ###########################################################################
  ANSIBLE_DEBUG_FLAG  = false
  AUTOMATION_FOLDER   = "/opt/EVOCLOUD"
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
  BASE_INSTALLER_IMG        = "evovm-os-8-10"
  DEPLOYER_PRIVATE_IP       = "10.10.10.5"
  DEPLOYER_BASE_VOLUME_TYPE = "10" # 0: Lower cost | 10: balanced | 20: Higher Performance | 30-120: Ultra High  #+1

  ###########################################################################
  # IDAM Identity and Access Management Server (FreeIPA)
  ###########################################################################
  IDAM_SHORT_HOSTNAME   = "evoidp" #+1
  BASE_IPASERVER_IMG    = "evovm-os-8-10"
  IDAM_PRIVATE_IP       = "10.10.20.5"
  IDAM_INSTANCE_SIZE    = "VM.Standard.E2.2"
  IDAM_BASE_VOLUME_TYPE = "10" # 0: Lower cost | 10: balanced | 20: Higher Performance | 30-120: Ultra High #+1

  ###########################################################################
  # IDAM Identity and Access Management Replica Server
  ###########################################################################
  IDAM_REPLICA_SHORT_HOSTNAME   = "evoidpr"
  IDAM_REPLICA_PRIVATE_IP       = "10.10.20.10"
  IDAM_REPLICA_INSTANCE_SIZE    = "VM.Standard.E2.2"
  IDAM_REPLICA_BASE_VOLUME_TYPE = "10" # 0: Lower cost | 10: balanced | 20: Higher Performance | 30-120: Ultra High

  ###########################################################################
  # Remote Desktop Server
  ###########################################################################
  RDP_SHORT_HOSTNAME   = "evodesktop"
  RDP_BASE_VOLUME_TYPE = "10" #0: Lower cost | 10: balanced | 20: Higher Performance | 30-120: Ultra High

  ###########################################################################
  # Virtual Cloud Desktop
  ###########################################################################
  VCD_SHORT_HOSTNAME   = "evodash"
  VCD_BASE_VOLUME_TYPE = "10" #0: Lower cost | 10: balanced | 20: Higher Performance | 30-120: Ultra High

  ###########################################################################
  # EvoHarbor Repository Server
  ###########################################################################
  EVOHARBOR_SHORT_HOSTNAME   = "evoharbor"
  EVOHARBOR_BASE_VOLUME_TYPE = "10" #0: Lower cost | 10: balanced | 20: Higher Performance | 30-120: Ultra High

  ###########################################################################
  # EvoCode Enterprise Code Repository Management Server
  ###########################################################################
  EVOCODE_SHORT_HOSTNAME   = "evogit"
  EVOCODE_BASE_VOLUME_TYPE = "10" #0: Lower cost | 10: balanced | 20: Higher Performance | 30-120: Ultra High

  ###########################################################################
  # EvoCode RUNNER Server
  ###########################################################################
  EVOCODE_RUNNER_SHORT_HOSTNAME   = "evogit-runner01"
  EVOCODE_RUNNER_BASE_VOLUME_TYPE = "10" #0: Lower cost | 10: balanced | 20: Higher Performance | 30-120: Ultra High

  ###########################################################################
  # Talos Kubernetes Cluster (Kubernetes)
  ###########################################################################
  #TALOS CONTROLPLANE NODES
  TALOS_CTRL_INSTANCE_SIZE    = "VM.Standard.E2.2"
  TALOS_CTRL_BASE_VOLUME_TYPE = "10" # 0: Lower cost | 10: balanced | 20: Higher Performance | 30-120: Ultra High
  TALOS_CTRL_NODES            = {
    node01 = "evotalos-cp01"
    node02 = "evotalos-cp02"
    node03 = "evotalos-cp03"
  }

  TALOS_AMI_NAME     = "evocluster-os-1-11-0"#+1
  TALOS_CTRL_INSTANCE_SIZE    = "VM.Standard.E4.Flex"
  TALOS_CTRL_BASE_VOLUME_TYPE = "10" # 0: Lower cost | 10: balanced | 20: Higher Performance | 30-120: Ultra High

  #TALOS EXTRA KUBERNETES MANIFESTS
  TALOS_EXTRA_MANIFESTS     = {
    gateway_api_std       = "https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.3.0/standard-install.yaml"
    gateway_api_exp       = "https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.3.0/experimental-install.yaml"
    kubelet_serving_cert  = "https://raw.githubusercontent.com/alex1989hu/kubelet-serving-cert-approver/main/deploy/standalone-install.yaml"
    kube-metric_server    = "https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml"
    local-storage_class   = "https://raw.githubusercontent.com/evocloud-dev/evocloud-k8s-manifests/refs/heads/main/local-storageclass.yaml"
    kube-buildpack        = "https://github.com/buildpacks-community/kpack/releases/download/v0.16.1/release-0.16.1.yaml"
  }

  #TALOS STANDALONE
  TALOS_CTRL_STANDALONE_SIZE   = "VM.Standard.E4.Flex"
  TALOS_STANDALONE_VOLUME_TYPE = "10" # 0: Lower cost | 10: balanced | 20: Higher Performance | 30-120: Ultra High
  TALOS_CTRL_STANDALONE        = {
    node01 = "evotalos-workstation"
  } #+1

  TALOS_LB_NODES            = {
    node01 = "evotalos-lb"
  }
  TALOS_LB_INSTANCE_SIZE    = "VM.Standard.E2.2"
  TALOS_LB_BASE_VOLUME_TYPE = "10" # 0: Lower cost | 10: balanced | 20: Higher Performance | 30-120: Ultra High

} # End inputs

#--------------------------------------------------
# Tfstate Remote State Storage
#--------------------------------------------------
remote_state {
  backend = "oci"
  config     = {
    namespace = "ax1xxxxxxxxxxxx"
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