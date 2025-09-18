# Takes approximately  hours to complete
#--------------------------------------------------
# Input Variables
#--------------------------------------------------
inputs = {
  deployer_server_eip = dependency.server-dmz-deployer.outputs.public_ip
  dmz_subnet_id       = dependency.network-subnet.outputs.dmz_subnet_id
  public_nsg          = dependency.network-security.outputs.public_nsg
  cluster_name        = "evo-cluster-std"
  talos_version       = "v1.11.0"
  kubernetes_version  = "v1.34.0"
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
# Load cluster-talos-standalone-helper module
#--------------------------------------------------
terraform {
  source = "${get_terragrunt_dir()}/../../compose//cluster-talos-standalone-helper"
}