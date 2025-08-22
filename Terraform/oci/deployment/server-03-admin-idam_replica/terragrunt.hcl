# Takes approximately 29 minutes to complete
#--------------------------------------------------
# Input Variables
#--------------------------------------------------
inputs = {
  admin_subnet_name     = dependency.network-subnet.outputs.admin_subnet_name
  admin_subnet_id       = dependency.network-subnet.outputs.admin_subnet_id
  deployer_server_eip   = dependency.server-dmz-deployer.outputs.public_ip
  idam_server_ip        = dependency.server-admin-idam.outputs.private_ip
  nsg_id                = dependency.network-gateway.outputs.evocloud_nsg_id
  vcn_id                = dependency.network-vcn.outputs.main_vcn_id
  idam_replica_revision = "0.1.0"
  use_spot              = true
}

#--------------------------------------------------
# Include root terragrunt.hcl file
#--------------------------------------------------
include "root" {
  path = find_in_parent_folders("root.hcl")
}

#--------------------------------------------------
# Set network-gateway module dependency
#--------------------------------------------------
dependency "network-vcn" {
  config_path   = "${get_terragrunt_dir()}/../network-01-vcn"
}

#--------------------------------------------------
# Set network-gateway module dependency
#--------------------------------------------------
dependency "network-gateway" {
  config_path   = "${get_terragrunt_dir()}/../network-02-gateway"
}

#--------------------------------------------------
# Set network-subnet module dependency
#--------------------------------------------------
dependency "network-subnet" {
  config_path   = "${get_terragrunt_dir()}/../network-03-subnet"
}

#--------------------------------------------------
# Set server-dmz-deployer module dependency
#--------------------------------------------------
dependency "server-dmz-deployer" {
  config_path   = "${get_terragrunt_dir()}/../server-01-dmz-deployer"
}

#--------------------------------------------------
# Load server-admin-idam module
#--------------------------------------------------
dependency "server-admin-idam"{
  config_path = "${get_terragrunt_dir()}/../server-02-admin-idam"
}

#--------------------------------------------------
# Load server-admin-idam_replica module
#--------------------------------------------------
terraform {
  source = "${get_terragrunt_dir()}/../../compose//server-admin-idam_replica"
}
