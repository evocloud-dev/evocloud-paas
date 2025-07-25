# Takes approximately 0 minutes to complete
#--------------------------------------------------
# Input Variables
#--------------------------------------------------
inputs = {
  backend_subnet_name   = dependency.network-subnet.outputs.backend_subnet_name
  deployer_server_eip   = dependency.server-dmz-deployer.outputs.public_ip
  idam_server_ip        = dependency.server-admin-idam.outputs.private_ip
  idam_replica_ip       = dependency.server-admin-idam_replica.outputs.private_ip
  evoharbor_revision    = "0.1.0"
  use_spot              = true
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
# Set server-admin-idam module dependency
#--------------------------------------------------
dependency "server-admin-idam" {
  config_path   = "${get_terragrunt_dir()}/../server-02-admin-idam"
}

dependency "server-admin-idam_replica" {
  config_path   = "${get_terragrunt_dir()}/../server-03-admin-idam_replica"
}

#--------------------------------------------------
# Load EvoHarbor module
#--------------------------------------------------
terraform {
  source = "${get_terragrunt_dir()}/../../compose//server-backend-evoharbor"
}