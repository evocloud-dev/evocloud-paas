# Takes approximately  hours to complete
#--------------------------------------------------
# Input Variables
#--------------------------------------------------
inputs = {
  dmz_subnet_name     = dependency.network-subnet.outputs.dmz_subnet_name
  idam_server_ip      = dependency.server-admin-idam.outputs.private_ip
  idam_replica_ip     = dependency.server-admin-idam_replica.outputs.private_ip
  cluster_name        = "evotalos-workstation"
  talos_version       = "v1.9.5"
  kubernetes_version  = "v1.32.3"
  create_talos_img    = false
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
# Set server-admin-idam module dependency
#--------------------------------------------------
dependency "server-admin-idam" {
  config_path   = "${get_terragrunt_dir()}/../server-02-admin-idam"
}

dependency "server-admin-idam_replica" {
  config_path   = "${get_terragrunt_dir()}/../server-03-admin-idam_replica"
}

#--------------------------------------------------
# Load Talos Kubernetes module
#--------------------------------------------------
terraform {
  source = "${get_terragrunt_dir()}/../../compose//cluster-talos-standalone"
}