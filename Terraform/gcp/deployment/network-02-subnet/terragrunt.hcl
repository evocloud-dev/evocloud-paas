#--------------------------------------------------
# Include root terragrunt.hcl file
#--------------------------------------------------
include {
  path = find_in_parent_folders()
}

#--------------------------------------------------
# Set network-vpc module dependency
#--------------------------------------------------
dependency "network-vpc" {
  config_path   = "${get_terragrunt_dir()}/../network-01-vpc"
  skip_outputs  = true
}

#--------------------------------------------------
# Load network-subnet module
#--------------------------------------------------
terraform {
  source = "${get_terragrunt_dir()}/../../compose//network-subnet"
}