# Takes approximately 25 minutes to complete
#--------------------------------------------------
# Input Variables
#--------------------------------------------------
inputs = {
  dmz_subnet_id       = dependency.network-subnet.outputs.dmz_subnet_id
  deployer_server_eip = dependency.server-dmz-deployer.outputs.deployer_server_ip
  gateway_revision    = "0.1.0"
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
# Set server-dmz-deployer module dependency
#--------------------------------------------------
dependency "server-dmz-deployer" {
  config_path   = "${get_terragrunt_dir()}/../server-01-dmz-deployer"
}

#--------------------------------------------------
# Load server-admin-idam module
#--------------------------------------------------
terraform {
  source = "${get_terragrunt_dir()}/../../compose//server-dmz-gateway"
}