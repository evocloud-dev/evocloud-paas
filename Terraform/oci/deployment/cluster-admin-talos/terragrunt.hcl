# Takes approximately  hours to complete
#--------------------------------------------------
# Input Variables
#--------------------------------------------------
inputs = {
  admin_subnet_id       = dependency.network-subnet.outputs.admin_subnet_id
  private_nsg           = dependency.network-security.outputs.private_nsg
  idam_server_ip        = dependency.server-admin-idam.outputs.private_ip
  idam_replica_ip       = dependency.server-admin-idam_replica.outputs.private_ip
  cluster_name        = "evo-cluster-mgr"
  talos_version       = "v1.11.0"
  kubernetes_version  = "v1.34.0"
  taloslb_revision    = "0.1.0"
  cluster_post_config_revision = "0.1.0"
  kubeapp_gateway_revision  = "0.1.0"
  taloslb_revision      = "0.1.0"
}

#--------------------------------------------------
# Include root terragrunt.hcl file
#--------------------------------------------------
include "root" {
  path = find_in_parent_folders("root.hcl")
}


#--------------------------------------------------
# Set network-security module dependency
#--------------------------------------------------
dependency "network-security" {
  config_path = "${get_terragrunt_dir()}/../network-03-security"
}

#--------------------------------------------------
# Set network-subnet module dependency
#--------------------------------------------------
dependency "network-subnet" {
  config_path   = "${get_terragrunt_dir()}/../network-04-subnet"
}

#--------------------------------------------------
# Set server-admin-idam module dependency
#--------------------------------------------------
dependency "server-admin-idam" {
  config_path   = "${get_terragrunt_dir()}/../server-02-admin-idam"
}

#--------------------------------------------------
# Set server-admin-idam-replica module dependency
#--------------------------------------------------
dependency "server-admin-idam_replica" {
  config_path   = "${get_terragrunt_dir()}/../server-03-admin-idam_replica"
}

#--------------------------------------------------
# Load Talos Kubernetes module
#--------------------------------------------------
terraform {
  source = "${get_terragrunt_dir()}/../../compose//cluster-admin-talos"
}