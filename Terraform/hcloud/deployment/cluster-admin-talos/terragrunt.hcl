# Takes approximately  hours to complete
#--------------------------------------------------
# Input Variables
#--------------------------------------------------
inputs = {
  vpc_id                       = dependency.network-vpc.outputs.vpc_id
  admin_subnet_id            = dependency.network-subnet.outputs.admin_subnet_id
  idam_server_ip               = dependency.server-admin-idam.outputs.private_ip
  idam_replica_ip              = dependency.server-admin-idam_replica.outputs.private_ip
  cluster_name                 = "evo-cluster-mgr"
  talos_version                = "v1.11.6"
  kubernetes_version           = "v1.34.0"
  taloslb_revision             = "0.1.0"
  cluster_post_config_revision = "0.1.0"
  kubeapp_gateway_revision     = "0.1.0"
}

#--------------------------------------------------
# Include root terragrunt.hcl file
#--------------------------------------------------
include "root" {
  path = find_in_parent_folders("root.hcl")
}

#--------------------------------------------------
# Set network-subnet module dependency
#--------------------------------------------------
dependency "network-subnet" {
  config_path   = "${get_terragrunt_dir()}/../network-02-subnet"
}

#--------------------------------------------------
# Set network-vpc module dependency
#--------------------------------------------------
dependency "network-vpc" {
  config_path   = "${get_terragrunt_dir()}/../network-01-vpc"
}

#--------------------------------------------------
# Set server-dmz-gateway module dependency
#--------------------------------------------------
dependency "server-dmz-gateway" {
  config_path   = "${get_terragrunt_dir()}/../server-02-dmz-gateway"
}

#--------------------------------------------------
# Set server-admin-idam module dependency
#--------------------------------------------------
dependency "server-admin-idam" {
  config_path   = "${get_terragrunt_dir()}/../server-03-admin-idam"
}

dependency "server-admin-idam_replica" {
  config_path   = "${get_terragrunt_dir()}/../server-04-admin-idam_replica"
}

#--------------------------------------------------
# Load Talos Kubernetes module
#--------------------------------------------------
terraform {
  source = "${get_terragrunt_dir()}/../../compose//cluster-admin-talos"
}