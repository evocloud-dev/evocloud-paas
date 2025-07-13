# Takes approximately 1h 37min to complete
#--------------------------------------------------
# Input Variables
#--------------------------------------------------
inputs = {
  dmz_subnet_name       = dependency.network-subnet.outputs.dmz_subnet_name
  deployer_revision     = "0.1.0"
  use_spot              = true

}

#--------------------------------------------------
# Include root terragrunt.hcl file
#--------------------------------------------------
include "root" {
  path = find_in_parent_folders("root.hcl")
}

#--------------------------------------------------
# Set network-subnet module dependency
#--------------------------------------------------
dependency "network-subnet" {
  config_path   = "${get_terragrunt_dir()}/../network-02-subnet"
}

#--------------------------------------------------
# Set network-routing module dependency
#--------------------------------------------------
dependency "network-routing" {
  config_path   = "${get_terragrunt_dir()}/../network-03-gateway"
  skip_outputs  = true
}

#--------------------------------------------------
# Load server-dmz-deployer module
#--------------------------------------------------
terraform {
  source = "${get_terragrunt_dir()}/../../compose//server-dmz-deployer"
}
