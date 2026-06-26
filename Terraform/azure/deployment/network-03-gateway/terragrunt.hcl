#--------------------------------------------------
# Include inputs
#--------------------------------------------------
inputs = {
  rg_name           = dependency.network-rg.outputs.main_rg_name
  rg_location       = dependency.network-rg.outputs.main_rg_location
  admin_subnet_id   = dependency.network-subnet.outputs.admin_subnet_id
  backend_subnet_id = dependency.network-subnet.outputs.backend_subnet_id
  dmz_subnet_id     = dependency.network-subnet.outputs.dmz_subnet_id
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
# Set network-rg module dependency
#--------------------------------------------------
dependency "network-rg" {
  config_path   = "${get_terragrunt_dir()}/../network-01-rg"
}

#--------------------------------------------------
# Load network-subnet module
#--------------------------------------------------
terraform {
  source = "${get_terragrunt_dir()}/../../compose//network-gateway"
}