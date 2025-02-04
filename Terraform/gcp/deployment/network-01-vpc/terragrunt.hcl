#--------------------------------------------------
# Include root terragrunt.hcl file
#--------------------------------------------------
include {
  path = find_in_parent_folders()
}

#--------------------------------------------------
# Load network-vpc module
#--------------------------------------------------
terraform {
  source = "${get_terragrunt_dir()}/../../compose//network-vpc"
}