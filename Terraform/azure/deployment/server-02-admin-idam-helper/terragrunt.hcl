#--------------------------------------------------
# Include inputs
#--------------------------------------------------
inputs = {
  deployer_server_eip = dependency.server-dmz-deployer.outputs.deployer_server_ip
  admin_subnet_id      = dependency.network-subnet.outputs.admin_subnet_id
  rg_name              = dependency.network-rg.outputs.main_rg_name
  rg_location          = dependency.network-rg.outputs.main_rg_location
  ssh_sgr              = dependency.network-sg.outputs.ssh_sgr
  idam_revision        = "0.1.0"
}


#--------------------------------------------------
# Include root terragrunt.hcl file
#--------------------------------------------------
include "root" {
  path = find_in_parent_folders("root.hcl")
}

#--------------------------------------------------
# Set server-dmz-deployer module dependency
#--------------------------------------------------
dependency "server-dmz-deployer" {
  config_path   = "${get_terragrunt_dir()}/../server-01-dmz-deployer"
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
  source = "${get_terragrunt_dir()}/../../compose//server-admin-idam-helper"
}