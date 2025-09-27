# Takes approximately  hours to complete
#--------------------------------------------------
# Input Variables
#--------------------------------------------------
inputs = {
  deployer_server_eip = dependency.server-dmz-deployer.outputs.public_ip
  dmz_subnet_id       = dependency.network-subnet.outputs.dmz_subnet_id
  public_nsg          = dependency.network-security.outputs.public_nsg
  idam_server_ip      = dependency.server-admin-idam.outputs.private_ip
  idam_replica_ip     = dependency.server-admin-idam_replica.outputs.private_ip
  vcd_revision        = "0.1.0"
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
# Set server-admin-idam-replica module dependency
#--------------------------------------------------
dependency "server-admin-idam_replica" {
  config_path   = "${get_terragrunt_dir()}/../server-03-admin-idam_replica"
}

#--------------------------------------------------
# Set server-admin-idam module dependency
#--------------------------------------------------
dependency "server-admin-idam" {
  config_path   = "${get_terragrunt_dir()}/../server-02-admin-idam"
}

#--------------------------------------------------
# Set server-dmz-deployer module dependency
#--------------------------------------------------
dependency "server-dmz-deployer" {
  config_path   = "${get_terragrunt_dir()}/../server-01-dmz-deployer"
}

#--------------------------------------------------
# Load server-dmz-vcd module
#--------------------------------------------------
terraform {
  source = "${get_terragrunt_dir()}/../../compose//server-dmz-vcd-helper"
}