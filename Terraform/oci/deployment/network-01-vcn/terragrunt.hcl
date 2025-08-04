#--------------------------------------------------
# Include root terragrunt.hcl file
#--------------------------------------------------
include "root" {
  path = find_in_parent_folders("root.hcl")
}

#--------------------------------------------------
# Load network-vpc module
#--------------------------------------------------
terraform {
  source = "${get_terragrunt_dir()}/../../compose//network-vcn"
}