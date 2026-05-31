#--------------------------------------------------
# Include inputs
#--------------------------------------------------
inputs = {
  rg_name              = dependency.network-rg.outputs.main_rg_name
  rg_location          = dependency.network-rg.outputs.main_rg_location
  dmz_subnet_id        = dependency.network-subnet.outputs.dmz_subnet_id
  ssh_sgr              = dependency.network-sg.outputs.ssh_sgr
  deployer_revision    = "0.1.0"
}


#--------------------------------------------------
# Include root terragrunt.hcl file
#--------------------------------------------------
include "root" {
  path = find_in_parent_folders("root.hcl")
}

#--------------------------------------------------
# Set network-sg module dependency
#--------------------------------------------------
dependency "network-sg" {
  config_path   = "${get_terragrunt_dir()}/../network-04-sg"
}

#--------------------------------------------------
# Set network-gateway module dependency
#--------------------------------------------------
dependency "network-gateway" {
  config_path   = "${get_terragrunt_dir()}/../network-03-gateway"
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
# Load server-01-dmz-deployer module
#--------------------------------------------------
terraform {
  source = "${get_terragrunt_dir()}/../../compose//server-dmz-deployer"
}