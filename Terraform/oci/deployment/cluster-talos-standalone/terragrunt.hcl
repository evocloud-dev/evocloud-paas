# Takes approximately  hours to complete
#--------------------------------------------------
# Input Variables
#--------------------------------------------------
inputs = {
  admin_subnet_id     = dependency.network-subnet.outputs.admin_subnet_id
  backend_subnet_id   = dependency.network-subnet.outputs.backend_subnet_id
  dmz_subnet_id       = dependency.network-subnet.outputs.dmz_subnet_id
  dmz_subnet_name     = dependency.network-subnet.outputs.dmz_subnet_name
  nsg_id              = dependency.network-gateway.outputs.evocloud_nsg_id
  vpc_id              = dependency.network-vpc.outputs.main_vpc_id
  #idam_server_ip      =
  #idam_replica_ip     =
  cluster_name        = "evo-cluster-std"
  talos_version       = "v1.10.5"
  kubernetes_version  = "v1.33.2"
  create_talos_img    = true
  use_spot            = true
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
dependency "network-vpc" {
  config_path = "${get_terragrunt_dir()}/../network-01-vpc"
}

#--------------------------------------------------
# Set network-subnet module dependency
#--------------------------------------------------
dependency "network-gateway" {
  config_path = "${get_terragrunt_dir()}/../network-02-gateway"
}

#--------------------------------------------------
# Set network-subnet module dependency
#--------------------------------------------------
dependency "network-subnet" {
  config_path   = "${get_terragrunt_dir()}/../network-03-subnet"
}

#--------------------------------------------------
# Set server-admin-idam module dependency
#--------------------------------------------------
#dependency "server-admin-idam" {
#  config_path   = "${get_terragrunt_dir()}/../server-02-admin-idam"
#}

#dependency "server-admin-idam_replica" {
#  config_path   = "${get_terragrunt_dir()}/../server-03-admin-idam_replica"
#}

#--------------------------------------------------
# Load Talos Kubernetes module
#--------------------------------------------------
terraform {
  source = "${get_terragrunt_dir()}/../../compose//cluster-talos-standalone"
}