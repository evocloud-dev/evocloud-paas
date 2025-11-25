#--------------------------------------------------
# Include inputs
#--------------------------------------------------
inputs = {
  vpc_id = dependency.network-vpc.outputs.vpc_id
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

#--------------------------------------------------
# Load network-subnet module
#--------------------------------------------------
terraform {
  source = "${get_terragrunt_dir()}/../../compose//network-subnet"
}