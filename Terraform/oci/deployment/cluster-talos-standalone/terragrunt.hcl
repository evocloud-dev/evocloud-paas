# Takes approximately  hours to complete
#--------------------------------------------------
# Input Variables
#--------------------------------------------------
inputs = {
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
# Set network-security module dependency
#--------------------------------------------------
dependency "network-security" {
  config_path = "${get_terragrunt_dir()}/../network-03-security"
}


#--------------------------------------------------
# Set network-subnet module dependency
#--------------------------------------------------
dependency "network-subnet" {
  config_path   = "${get_terragrunt_dir()}/../network-04-subnet"
}

#--------------------------------------------------
# Load Talos Kubernetes module
#--------------------------------------------------
terraform {
  source = "${get_terragrunt_dir()}/../../compose//cluster-talos-standalone"
}