# Takes approximately hours to complete
#--------------------------------------------------
# Input Variables
#--------------------------------------------------
inputs = {
  backend_subnet_id   = dependency.network-subnet.outputs.backend_subnet_id
  private_nsg         = dependency.network-security.outputs.private_nsg
  idam_server_ip        = dependency.server-admin-idam.outputs.private_ip
  idam_replica_ip       = dependency.server-admin-idam_replica.outputs.private_ip
  evocode_revision      = "0.1.0"
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
# EvoCODE Repository Server module
#--------------------------------------------------
terraform {
  source = "${get_terragrunt_dir()}/../../compose//server-backend-evocode"
}
