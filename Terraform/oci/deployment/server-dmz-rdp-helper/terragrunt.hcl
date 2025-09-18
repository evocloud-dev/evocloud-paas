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
  rdp_revision        = "0.1.0"
}

#--------------------------------------------------
# Include root terragrunt.hcl file
#--------------------------------------------------
include "root" {
  path = find_in_parent_folders("root.hcl")
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
terraform {
  source = "${get_terragrunt_dir()}/../../compose//server-dmz-rdp-helper"
}