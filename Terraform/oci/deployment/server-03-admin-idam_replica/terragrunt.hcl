# Takes approximately  hours to complete
#--------------------------------------------------
# Input Variables
#--------------------------------------------------
inputs = {
  admin_subnet_id     = dependency.network-subnet.outputs.admin_subnet_id
  private_nsg          = dependency.network-security.outputs.private_nsg
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
# IDAM REPLICA module
#--------------------------------------------------
terraform {
  source = "${get_terragrunt_dir()}/../../compose//server-admin-idam_replica"
}
