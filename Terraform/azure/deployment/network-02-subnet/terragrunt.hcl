#--------------------------------------------------
# Include inputs
#--------------------------------------------------
inputs = {
  rg_name   = dependency.network-rg.outputs.main_rg_name
  vnet_name = dependency.network-rg.outputs.vnet_name
}


#--------------------------------------------------
# Include root terragrunt.hcl file
#--------------------------------------------------
include "root" {
  path = find_in_parent_folders("root.hcl")
}

#--------------------------------------------------
# Set network-rg module dependency
#--------------------------------------------------
dependency "network-rg" {
  config_path   = "${get_terragrunt_dir()}/../network-01-rg"
}

#--------------------------------------------------
# Load network-subnet module
#--------------------------------------------------
terraform {
  source = "${get_terragrunt_dir()}/../../compose//network-subnet"
}