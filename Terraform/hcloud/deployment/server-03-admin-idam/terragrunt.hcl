# Takes approximately 25 minutes to complete
#--------------------------------------------------
# Input Variables
#--------------------------------------------------
inputs = {
  admin_subnet_id     = dependency.network-subnet.outputs.admin_subnet_id
  deployer_server_eip = dependency.server-dmz-deployer.outputs.deployer_server_ip
  idam_revision       = "0.1.0"
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
# Set server-dmz-gateway module dependency
#--------------------------------------------------
dependency "server-dmz-gateway" {
  config_path   = "${get_terragrunt_dir()}/../server-02-dmz-gateway"
}

#--------------------------------------------------
# Load server-admin-idam module
#--------------------------------------------------
terraform {
  source = "${get_terragrunt_dir()}/../../compose//server-admin-idam"
}