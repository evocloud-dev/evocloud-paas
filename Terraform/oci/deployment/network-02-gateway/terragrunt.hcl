#--------------------------------------------------
# Include inputs
#--------------------------------------------------
inputs = {
  vcn_id = dependency.network-vcn.outputs.main_vcn_id
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

#--------------------------------------------------
# Load network-gateway module
#--------------------------------------------------
terraform {
  source = "${get_terragrunt_dir()}/../../compose//network-gateway"
}