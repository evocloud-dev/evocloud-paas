#--------------------------------------------------
# Include inputs
#--------------------------------------------------
inputs = {
  public_rt_table   = dependency.network-gateway.outputs.evocloud_public_rt
  private_rt_table  = dependency.network-gateway.outputs.evocloud_private_rt
  vcn_id            = dependency.network-vcn.outputs.main_vcn_id
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
dependency "network-vcn" {
  config_path   = "${get_terragrunt_dir()}/../network-01-vcn"
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