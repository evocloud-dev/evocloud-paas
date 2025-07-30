#--------------------------------------------------
# Include inputs
#--------------------------------------------------
inputs = {
  public_rt_table   = dependency.network-gateway.outputs.evocloud_public_rt
  private_rt_table  = dependency.network-gateway.outputs.evocloud_private_rt
  vpc_id            = dependency.network-vpc.outputs.main_vpc_id
}

#--------------------------------------------------
# Include root terragrunt.hcl file
#--------------------------------------------------
include "root" {
  path = find_in_parent_folders("root.hcl")
}

#--------------------------------------------------
# Set network-vpc module dependency
#--------------------------------------------------
dependency "network-vpc" {
  config_path   = "${get_terragrunt_dir()}/../network-01-vpc"
}

dependency "network-gateway" {
  config_path   = "${get_terragrunt_dir()}/../network-02-gateway"
}

#--------------------------------------------------
# Load network-subnet module
#--------------------------------------------------
terraform {
  source = "${get_terragrunt_dir()}/../../compose//network-subnet"
}