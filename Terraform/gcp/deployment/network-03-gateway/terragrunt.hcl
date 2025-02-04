#--------------------------------------------------
# Include root terragrunt.hcl file
#--------------------------------------------------
include {
  path = find_in_parent_folders()
}

#--------------------------------------------------
# Set network-subnet module dependency
#--------------------------------------------------
dependency "network-subnet" {
  config_path   = "${get_terragrunt_dir()}/../network-02-subnet"
}

#--------------------------------------------------
# Load network-gateway module
#--------------------------------------------------
terraform {
  source = "${get_terragrunt_dir()}/../../compose//network-gateway"
}