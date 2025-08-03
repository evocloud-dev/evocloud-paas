#----------------------------------------------------------------------------------------------------
# INPUTS GLOBAL VARIABLES. All variables declare here must use the upper case naming convention
#----------------------------------------------------------------------------------------------------
inputs = {
  ###########################################################################
  # Miscellaneous Variables
  ###########################################################################

  DOMAIN_TLD     = "evocloud.dev"
  #GCP_METADATA_NS = "169.254.169.254" #Changes depending on zone
  #CLOUD_PLATFORM = "gcp"

  ###########################################################################
  # Common Variables
  ###########################################################################
  BASE_VOLUME_50    = "50"
  CLOUD_USER        = "mlkroot"
  #DEFAULT_TIMEZONE = "America/Detroit"
  OCI_PROFILE       = "DEFAULT"
  #OCI_PROJECT_ID    = "change me"
  OCI_REGION        = "us-ashburn-1"
  OCI_AD            = []

  ###########################################################################
  # Network Configurations
  ###########################################################################
  OCI_VPC             = "evocloud-vpc"
  OCI_VPC_CIDR        = ["10.10.0.0/16"]
  
  ADMIN_SUBNET_CIDR   = "10.10.20.0/24"
  BACKEND_SUBNET_CIDR = "10.10.30.0/24"
  DMZ_SUBNET_CIDR     = "10.10.10.0/24"

  ###########################################################################
  # Talos Kubernetes Cluster (Kubernetes)
  ###########################################################################
  TALOS_AMI_NAME     = "evocloud-talos19-b010"
  TALOS_CTRL_INSTANCE_SIZE    = "e2-standard-4"
  TALOS_CTRL_BASE_VOLUME_TYPE = "pd-standard" #pd-standard | pd-balanced | pd-ssd | pd-extreme

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
#remote_state {
#  backend = "oci"
#  config     = {
#    project  = "evocloud-dev"
#    location = "us"
#    bucket   = "evocloud-tf-state"
#    prefix   = "${basename(get_parent_terragrunt_dir())}/${path_relative_to_include()}"
#  }
#}

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