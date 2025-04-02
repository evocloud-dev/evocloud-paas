variable "GCP_REGION" {
  description = "GCP Region"
  type        = string
  default     = "us-east5"
}

variable "GCP_REGIONS" {
  description = "List of GCP High Availability Regions to use"
  type        = list(string)
  default     = ["us-east5-a", "us-east5-b", "us-east5-c"]
}

variable "GCP_PROJECT_ID" {
  description = "GCP Project ID"
  type        = string
  default     = "geanttech-evocloud"
}

variable "CLOUD_USER" {
  description = "Server Default Login User"
  type        = string
  default     = "mlkroot"
}

variable "DOMAIN_TLD" {
  description = "Platform Domain Name"
  type        = string
  default     = "evocloud-test.dev"
}

variable "TALOS_AMI_NAME" {
  description = "Talos Base AMI Name"
  type        = string
  default     = "evocloud-talos19-b010"
}

variable "TALOS_AMI_SOURCE" {
  description = "Link to the Talos OS Raw Disk"
  type        = string
  default     = "https://storage.cloud.google.com/evocloud-cnpg-cluster-backup/gcp-amd64.raw.tar.gz"
}

variable "BASE_VOLUME_10" {
  description = "Base Volume Size 10GB"
  type        = string
  default     = "10"
}

variable "TALOS_CTRL_STANDALONE_SIZE" {
  description = "Talos Standalone Controlplane Compute Instance Flavor Size"
  type        = string
  default     = "e2-standard-2"
}


variable "TALOS_STANDALONE_VOLUME_TYPE" {
  description = "Talos VM Base Volume Type"
  type        = string
  default     = "pd-balanced"
}

variable "TALOS_CTRL_STANDALONE" {
  description = "Talos Standalone Controlplane Nodes"
  type = map(string)
  default = {
    node01 = "evotalos-workstation02"
  }
}

variable "TALOS_EXTRA_MANIFESTS" {
  description = "Extra Kubernetes Manifest for Talos Machine Configuration"
  type = map(string)
  default = {
    gateway_api_std       = "https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.1/standard-install.yaml"
    gateway_api_tls       = "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.1/config/crd/experimental/gateway.networking.k8s.io_tlsroutes.yaml"
    cilium_manifest       = "https://raw.githubusercontent.com/geanttechnology/evocloud-k8s-manifests/refs/heads/main/cilium.yaml"
    rook_ceph_operator    = "https://raw.githubusercontent.com/geanttechnology/evocloud-k8s-manifests/refs/heads/main/rook-operator.yaml"
    rook_ceph_cluster     = "https://raw.githubusercontent.com/geanttechnology/evocloud-k8s-manifests/refs/heads/main/rook-cluster.yaml"
    headlamp_ui           = "https://raw.githubusercontent.com/geanttechnology/evocloud-k8s-manifests/refs/heads/main/kubernetes-headlamp.yaml"
    kyverno_policy        = "https://github.com/kyverno/kyverno/releases/download/v1.13.2/install.yaml"
    kubelet_serving_cert  = "https://raw.githubusercontent.com/alex1989hu/kubelet-serving-cert-approver/main/deploy/standalone-install.yaml"
    kube-metric_server    = "https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml"
    flux-cd-operator      = "https://github.com/controlplaneio-fluxcd/flux-operator/releases/latest/download/install.yaml"
    local-storage_class   = "https://raw.githubusercontent.com/evocloud-dev/evocloud-k8s-manifests/refs/heads/main/local-storageclass.yaml"
  }
}

variable "GCP_METADATA_NS" {
  description = "GCP Metadata Nameserver IP"
  type        = string
  default     = "169.254.169.254"
}

variable "dmz_subnet_name" {
  description = "Output for DMZ Subnet Name"
  type        = string
  default     = "dmz-subnet"
}


variable "idam_server_ip" {
  description = "IDAM Server Private IPv4"
  type        = string
  default = "10.10.20.5"
}

variable "idam_replica_ip" {
  description = "IDAM Replica Server Private IPv4"
  type        = string
  default     = "10.10.20.10"
}

variable "cluster_name" {
  description = "Talos Kubernetes Cluster Name"
  type        = string
  default     = "tofu-talos"
}

variable "talos_version" {
  description = "Talos version to use in generating machine configuration"
  default     = "1.9.5"
}

variable "kubernetes_version" {
  description = "Kubernetes version to use for the Talos Cluster"
  default     = "1.32.3"
}

variable "create_talos_img" {
  description = "Boolean variable to determine whether to create the Talos Base Image"
  type        = bool
  default     = false
}
