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
  BASE_AMI_NAME          = "evocloud-rocky-linux-8-b0-1-2"
  BASE_AMI_VERSION       = "8.10"
  BASE_SOURCE            = "Rocky-8-GenericCloud-Base.latest.x86_64.qcow2"
  BASE_VOLUME_50         = "50"
  CLOUD_USER             = "mlkroot"
  DEFAULT_TIMEZONE       = "America/Detroit"
  OCI_PROFILE            = "DEFAULT"
  OCI_REGION             = "us-ashburn-1"
  OCI_AD                 = []
  OCI_IMAGE_BUCKET       = ""
  TALOS_SOURCE           = "oracle-amd64.raw.xz"
  PUBLIC_KEY_PAIR        = "/etc/pki/tls/oci_evocloud.pub"
  PRIVATE_KEY_PAIR       = "/etc/pki/tls/oci_evocloud.pem"
  PUBLIC_NODE_KEY_PAIR   = "/etc/pki/tls/oci_evonode.pem"
  PRIVATE_NODE_KEY_PAIR  = "/etc/pki/tls/oci_evonode.pem"
  OCI_CONFIG             = "config"

  ###########################################################################
  # Ansible/Automation Runtime Environment Configurations
  ###########################################################################
  ANSIBLE_DEBUG_FLAG  = false
  AUTOMATION_FOLDER   = "/opt/EVOCLOUD"
  AUTOMATION_LOGS     = "/opt/EVOCLOUD/Logs"

  ###########################################################################
  # Network Configurations
  ###########################################################################
  OCI_VPC             = "evocloud-vpc"
  OCI_VPC_CIDR        = ["10.10.0.0/16"]
  
  ADMIN_SUBNET_CIDR   = "10.10.20.0/24"
  BACKEND_SUBNET_CIDR = "10.10.30.0/24"
  DMZ_SUBNET_CIDR     = "10.10.10.0/24"

  ###########################################################################
  # DMZ Controller Host
  ###########################################################################
  DEPLOYER_SHORT_HOSTNAME   = "evo-master"
  BASE_INSTALLER_IMG        = "evocloud-rocky8-b0-1-0"
  DEPLOYER_PRIVATE_IP       = "10.10.10.5"
  DEPLOYER_INSTANCE_SIZE    = "VM.Standard.E2.2"
  DEPLOYER_BASE_VOLUME_TYPE = "10" # 0: Lower cost | 10: balanced | 20: Higher Performance | 30-120: Ultra High

  ###########################################################################
  # IDAM Identity and Access Management Server (FreeIPA)
  ###########################################################################
  IDAM_SHORT_HOSTNAME   = "evoidp"
  BASE_IPASERVER_IMG    = "evocloud-rocky8-b0-1-0"
  IDAM_PRIVATE_IP       = "10.10.20.5"
  IDAM_INSTANCE_SIZE    = "VM.Standard.E2.2"
  IDAM_BASE_VOLUME_TYPE = "10" # 0: Lower cost | 10: balanced | 20: Higher Performance | 30-120: Ultra High

  ###########################################################################
  # IDAM Identity and Access Management Replica Server
  ###########################################################################
  IDAM_REPLICA_SHORT_HOSTNAME   = "evoidpr"
  IDAM_REPLICA_PRIVATE_IP       = "10.10.20.10"
  IDAM_REPLICA_INSTANCE_SIZE    = "VM.Standard.E2.2"
  IDAM_REPLICA_BASE_VOLUME_TYPE = "10" # 0: Lower cost | 10: balanced | 20: Higher Performance | 30-120: Ultra High

  ###########################################################################
  # Talos Kubernetes Cluster (Kubernetes)
  ###########################################################################
  TALOS_AMI_NAME     = "evocloud-talos19-b010"
  TALOS_CTRL_INSTANCE_SIZE    = "VM.Standard.E2.2"
  TALOS_CTRL_BASE_VOLUME_TYPE = "10" # 0: Lower cost | 10: balanced | 20: Higher Performance | 30-120: Ultra High

  #TALOS EXTRA KUBERNETES MANIFESTS
  TALOS_EXTRA_MANIFESTS   = {
    gateway_api_std       = "https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.1/standard-install.yaml"
    gateway_api_tls       = "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.1/config/crd/experimental/gateway.networking.k8s.io_tlsroutes.yaml"
    cilium_manifest       = "https://raw.githubusercontent.com/evocloud-dev/evocloud-k8s-manifests/refs/heads/main/cilium-1.17.3.yaml"
    rook_ceph_operator    = "https://raw.githubusercontent.com/evocloud-dev/evocloud-k8s-manifests/refs/heads/main/rook-operator-v1.17.1.yaml"
    rook_ceph_cluster     = "https://raw.githubusercontent.com/evocloud-dev/evocloud-k8s-manifests/refs/heads/main/rook-cluster-v1.17.1.yaml"
    headlamp_ui           = "https://raw.githubusercontent.com/geanttechnology/evocloud-k8s-manifests/refs/heads/main/kubernetes-headlamp.yaml"
    kyverno_policy        = "https://github.com/kyverno/kyverno/releases/download/v1.14.0/install.yaml"
    kubelet_serving_cert  = "https://raw.githubusercontent.com/alex1989hu/kubelet-serving-cert-approver/main/deploy/standalone-install.yaml"
    kube-metric_server    = "https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml"
    local-storage_class   = "https://raw.githubusercontent.com/evocloud-dev/evocloud-k8s-manifests/refs/heads/main/local-storageclass.yaml"
    kube-buildpack        = "https://github.com/buildpacks-community/kpack/releases/download/v0.16.1/release-0.16.1.yaml"
  }

  #TALOS STANDALONE
  TALOS_CTRL_STANDALONE_SIZE   = "VM.Standard.E2.2"
  TALOS_STANDALONE_VOLUME_TYPE = "10" # 0: Lower cost | 10: balanced | 20: Higher Performance | 30-120: Ultra High
  TALOS_CTRL_STANDALONE        = {
    node01 = "evotalos-workstation"
  }
} # End inputs

#--------------------------------------------------
# Tfstate Remote State Storage
#--------------------------------------------------
remote_state {
  backend = "oci"
  config     = {
    namespace = "idusyeyhcv4e"
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