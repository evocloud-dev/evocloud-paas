variable "GCP_REGION" {
  description = "GCP Region"
  type        = string
}

variable "GCP_REGIONS" {
  description = "List of GCP High Availability Regions to use"
  type        = list(string)
}

variable "GCP_PROJECT_ID" {
  description = "GCP Project ID"
  type        = string
}

variable "CLOUD_USER" {
  description = "Server Default Login User"
  type        = string
}

variable "PRIVATE_KEY_PAIR" {
  description = "Private Key Pair for SSH Login"
  type        = string
}

variable "ANSIBLE_DEBUG_FLAG" {
  description = "Ansible Debug Flag"
  type        = bool
}

variable "AUTOMATION_FOLDER" {
  description = "Ansible Code Root Folder"
  type        = string
}

variable "DOMAIN_TLD" {
  description = "Platform Domain Name"
  type        = string
}

variable "DEFAULT_TIMEZONE" {
  description = "Platform Default Timezone"
  type        = string
}

variable "BASE_AMI_NAME" {
  description = "Base AMI Name"
  type        = string
}

variable "TALOS_AMI_NAME" {
  description = "Talos Base AMI Name"
  type        = string
}

variable "TALOS_AMI_SOURCE" {
  description = "Link to the Talos OS Raw Disk"
  type        = string
}

variable "BASE_VOLUME_SIZE" {
  description = "Base Volume Size in GB"
  type        = string
}

variable "BASE_VOLUME_50" {
  description = "Base Volume Size 50GB"
  type        = string
}

variable "TALOS_CTRL_INSTANCE_SIZE" {
  description = "Talos Controlplane Compute Instance Flavor Size"
  type        = string
}

variable "TALOS_WKLD_INSTANCE_SIZE" {
  description = "Talos Workload Compute Instance Flavor Size"
  type        = string
}

variable "TALOS_CTRL_BASE_VOLUME_TYPE" {
  description = "Talos Controlplane Base Volume Type"
  type        = string
}

variable "TALOS_WKLD_BASE_VOLUME_TYPE" {
  description = "Talos Workload Base Volume Type"
  type        = string
}

variable "TALOS_WKLD_EXTRA_VOLUME_TYPE" {
  description = "Talos Workload Extra Volume Type"
  type        = string
}

variable "BASE_VOLUME_200" {
  description = "Talos Workload Extra Volume 200GB"
  type        = string
}

variable "TALOS_LB_INSTANCE_SIZE" {
  description = "TalosLoadBalancer Compute Instance Flavor Size"
  type        = string
}

variable "TALOS_LB_BASE_VOLUME_TYPE" {
  description = "Talos LoadBalancer Base Volume Type"
  type        = string
}

variable "TALOS_LB_NODES" {
  description = "Evokube LoadBalancer Nodes"
  type = map(string)
}

variable "TALOS_CTRL_NODES" {
  description = "Talos Controlplane Nodes"
  type = map(string)
}

variable "TALOS_WKLD_NODES" {
  description = "Talos Worker Nodes"
  type = map(object({
    short_name = string
    extra_volume = bool
  }))
}

variable "TALOS_EXTRA_MANIFESTS" {
  description = "Extra Kubernetes Manifest for Talos Machine Configuration"
  type = map(string)
}

variable "IDAM_SHORT_HOSTNAME" {
  description = "IDAM Server Short Hostname"
  type        = string
}

variable "PUBLIC_KEY_PAIR" {
  description = "SSH Server Key Path"
  type        = string
}

variable "GCP_METADATA_NS" {
  description = "GCP Metadata Nameserver IP"
  type        = string
}

variable "ADMIN_SUBNET_CIDR_LBIPAM" {
  description = "ADMIN Subnet CIDR for Cilium Loadbalancer LB-IPAM"
  type        = string
}

variable "use_spot" {
  description = "Use Ephemeral VM Instances that can be Terminated"
  type        = bool
}

variable "admin_subnet_name" {
  description = "Output for ADMIN Subnet Name"
  type        = string
}

variable "deployer_server_eip" {
  description = "Deployer Server Public IP"
  type        = string
}

variable "idam_server_ip" {
  description = "IDAM Server Private IPv4"
  type        = string
}

variable "idam_replica_ip" {
  description = "IDAM Replica Server Private IPv4"
  type        = string
}

variable "cluster_name" {
  description = "Talos Kubernetes Cluster Name"
  type        = string
}

variable "talos_version" {
  description = "Talos version to use in generating machine configuration"
}

variable "kubernetes_version" {
  description = "Kubernetes version to use for the Talos Cluster"
}

variable "taloslb_revision" {
  description = "Talos Apiserver loadbalancer revision version"
}

variable "create_talos_img" {
  description = "Boolean variable to determine whether to create the Talos Base Image"
  type        = bool
  default     = false
}

variable "cluster_post_config_revision" {
  description = "Cluster Admin Post Configs version"
}

variable "kubeapp_gateway_revision" {
  description = "Kubernetes Application Gateway Endpoint version"
}
