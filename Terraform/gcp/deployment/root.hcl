#----------------------------------------------------------------------------------------------------
# INPUTS GLOBAL VARIABLES. All variables declare here must use the upper case naming convention
#----------------------------------------------------------------------------------------------------
inputs = {
  ###########################################################################
  # Miscellaneous Variables
  ###########################################################################
  DOMAIN_TLD      = "evocloud.dev"
  GCP_METADATA_NS = "169.254.169.254" #Changes depending on zone
  CLOUD_PLATFORM  = "gcp"

  ###########################################################################
  # Common Variables
  ###########################################################################
  DEFAULT_TIMEZONE  = "America/Detroit"
  GCP_PROJECT_ID    = "evocloud-dev"
  GCP_REGION        = "us-east5"
  GCP_REGIONS       = ["us-east5-a", "us-east5-b", "us-east5-c"]
  GCP_VPC           = "evocloud-vpc"
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
  GCP_JSON_CREDS    = "geanttech-evocloud-aa3aa17df584.json"

  ###########################################################################
  # Ansible/Automation Runtime Environment Configurations
  ###########################################################################
  ANSIBLE_DEBUG_FLAG = false
  AUTOMATION_FOLDER = "/opt/EVOCLOUD"
  AUTOMATION_LOGS = "/opt/EVOCLOUD/Logs"

  ###########################################################################
  # Network Configurations
  ###########################################################################
  DMZ_SUBNET_CIDR = "10.10.10.0/24"
  ADMIN_SUBNET_CIDR = "10.10.20.0/24"
  BACKEND_SUBNET_CIDR = "10.10.30.0/24"

  ###########################################################################
  # DMZ Controller Host
  ###########################################################################
  DEPLOYER_SHORT_HOSTNAME   = "evo-master"
  BASE_INSTALLER_IMG        = "evocloud-rocky8-b0-1-0"
  DEPLOYER_PRIVATE_IP       = "10.10.10.5"
  DEPLOYER_INSTANCE_SIZE    = "e2-medium"
  DEPLOYER_BASE_VOLUME_TYPE = "pd-balanced" #pd-standard | pd-balanced | pd-ssd | pd-extreme

  ###########################################################################
  # IDAM Identity and Access Management Server (FreeIPA)
  ###########################################################################
  IDAM_SHORT_HOSTNAME   = "evoidp"
  BASE_IPASERVER_IMG    = "evocloud-rocky8-b0-1-0"
  IDAM_PRIVATE_IP       = "10.10.20.5"
  IDAM_INSTANCE_SIZE    = "e2-medium"
  IDAM_BASE_VOLUME_TYPE = "pd-balanced" #pd-standard | pd-balanced | pd-ssd | pd-extreme

  ###########################################################################
  # IDAM Identity and Access Management Replica Server
  ###########################################################################
  IDAM_REPLICA_SHORT_HOSTNAME   = "evoidpr"
  IDAM_REPLICA_PRIVATE_IP       = "10.10.20.10"
  IDAM_REPLICA_INSTANCE_SIZE    = "e2-medium"
  IDAM_REPLICA_BASE_VOLUME_TYPE = "pd-balanced" #pd-standard | pd-balanced | pd-ssd | pd-extreme

  ###########################################################################
  # Remote Desktop Server
  ###########################################################################
  RDP_SHORT_HOSTNAME   = "evodesktop"
  RDP_INSTANCE_SIZE    = "e2-medium"
  RDP_BASE_VOLUME_TYPE = "pd-balanced" #pd-standard | pd-balanced | pd-ssd | pd-extreme

  ###########################################################################
  # EvoCode Enterprise Code Repository Platform (Gitlab)
  ###########################################################################
  EVOCODE_SHORT_HOSTNAME   = "evocode"
  EVOCODE_INSTANCE_SIZE    = "e2-standard-4"
  EVOCODE_BASE_VOLUME_TYPE = "pd-balanced" #pd-standard | pd-balanced | pd-ssd | pd-extreme

  ###########################################################################
  # EvoCode Runner Code Executor for the EvoCode Platform (Gitlab-Runner)
  ###########################################################################
  EVOCODE_RUNNER_SHORT_HOSTNAME   = "evocode-runner"
  EVOCODE_RUNNER_INSTANCE_SIZE    = "e2-standard-4"
  EVOCODE_RUNNER_BASE_VOLUME_TYPE = "pd-balanced" #pd-standard | pd-balanced | pd-ssd | pd-extreme

  ###########################################################################
  # Talos Kubernetes Cluster (Kubernetes)
  ###########################################################################
  TALOS_AMI_NAME              = "evocloud-talos19-b010"
  TALOS_AMI_SOURCE            = "https://storage.cloud.google.com/evocloud-cnpg-cluster-backup/gcp-amd64.raw.tar.gz" #https://factory.talos.dev/image/96f8c146a67c80daad900d3fc1a6976fe11062321eee9ab6ae2a6aea88b2d26e/v1.9.5/gcp-amd64.raw.tar.gz

  #TALOS CONTROLPLANE NODES
  TALOS_CTRL_INSTANCE_SIZE    = "e2-standard-4"
  TALOS_CTRL_BASE_VOLUME_TYPE = "pd-balanced" #pd-standard | pd-balanced | pd-ssd | pd-extreme
  TALOS_CTRL_NODES            = {
    node01 = "evotalos-cp01"
    node02 = "evotalos-cp02"
    node03 = "evotalos-cp03"
  }

  #TALOS WORKER NODES
  TALOS_WKLD_INSTANCE_SIZE      = "e2-standard-4"
  TALOS_WKLD_BASE_VOLUME_TYPE   = "pd-balanced" #pd-standard | pd-balanced | pd-ssd | pd-extreme
  TALOS_WKLD_EXTRA_VOLUME_TYPE  = "pd-balanced"
  TALOS_WKLD_NODES              = {
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
  }

  #TALOS LOADBALANCER NODE
  TALOS_LB_INSTANCE_SIZE    = "e2-standard-2"
  TALOS_LB_BASE_VOLUME_TYPE = "pd-balanced" #pd-standard | pd-balanced | pd-ssd | pd-extreme
  TALOS_LB_NODES            = {
    node01 = "evotalos-lb"
  }

  #TALOS EXTRA KUBERNETES MANIFESTS
  TALOS_EXTRA_MANIFESTS     = {
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
  TALOS_CTRL_STANDALONE_SIZE    = "e2-standard-4"
  TALOS_STANDALONE_VOLUME_TYPE  = "pd-balanced"
  TALOS_CTRL_STANDALONE            = {
    node01 = "evotalos-workstation"
  }

}

#--------------------------------------------------
# Tfstate Remote State Storage
#--------------------------------------------------
remote_state {
  backend = "gcs"
  config = {
    project  = "evocloud-dev"
    location = "us"
    bucket   = "evocloud-tf-state"
    prefix   = "${basename(get_parent_terragrunt_dir())}/${path_relative_to_include()}"
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