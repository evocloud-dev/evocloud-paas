# Takes approximately 29 minutes to complete
#--------------------------------------------------
# Input Variables
#--------------------------------------------------
inputs = {
  admin_subnet_name     = dependency.network-subnet.outputs.admin_subnet_name
  deployer_server_eip   = dependency.server-dmz-deployer.outputs.public_ip
  idam_server_ip        = dependency.server-admin-idam.outputs.private_ip
  idam_replica_revision = "0.0.1"
}

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
# Set server-dmz-deployer module dependency
#--------------------------------------------------
dependency "server-dmz-deployer" {
  config_path   = "${get_terragrunt_dir()}/../server-01-dmz-deployer"
}

#--------------------------------------------------
# Set server-admin-idam module dependency
#--------------------------------------------------
dependency "server-admin-idam" {
  config_path   = "${get_terragrunt_dir()}/../server-02-admin-idam"
}

#--------------------------------------------------
# Load server-admin-idam_replica module
#--------------------------------------------------
terraform {
  source = "${get_terragrunt_dir()}/../../compose//server-admin-idam_replica"
}
