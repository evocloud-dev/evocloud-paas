# Takes approximately  hours to complete
#--------------------------------------------------
# Input Variables
#--------------------------------------------------
inputs = {
  admin_subnet_id     = dependency.network-subnet.outputs.admin_subnet_id
  backend_subnet_id   = dependency.network-subnet.outputs.backend_subnet_id
  dmz_subnet_id       = dependency.network-subnet.outputs.dmz_subnet_id
  dmz_subnet_name     = dependency.network-subnet.outputs.dmz_subnet_name
  nsg_id              = dependency.network-gateway.outputs.evocloud_nsg_id
  vcn_id              = dependency.network-vcn.outputs.main_vcn_id
  rocky_image_id      = dependency.image-build.outputs.rocky_linux_image_id
  rocky_image_name    = dependency.image-build.outputs.rocky_linux_image_name
  deployer_revision     = "0.1.0"
  use_spot            = true
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
dependency "network-vcn" {
  config_path = "${get_terragrunt_dir()}/../network-01-vcn"
}

#--------------------------------------------------
# Set network-subnet module dependency
#--------------------------------------------------
dependency "network-gateway" {
  config_path = "${get_terragrunt_dir()}/../network-02-gateway"
}

#--------------------------------------------------
# Set network-subnet module dependency
#--------------------------------------------------
dependency "network-subnet" {
  config_path   = "${get_terragrunt_dir()}/../network-03-subnet"
}

#--------------------------------------------------
# Load Talos Kubernetes module
#--------------------------------------------------
terraform {
  source = "${get_terragrunt_dir()}/../../compose//server-dmz-deployer"
}