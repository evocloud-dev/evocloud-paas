# Takes approximately  hours to complete
#--------------------------------------------------
# Input Variables
#--------------------------------------------------
inputs = {
  admin_subnet_name   = dependency.network-subnet.outputs.admin_subnet_name
  deployer_server_eip = dependency.server-dmz-deployer.outputs.public_ip
  idam_server_ip      = dependency.server-admin-idam.outputs.private_ip
  idam_replica_ip     = dependency.server-admin-idam_replica.outputs.private_ip
  cluster_name        = "evokube-mgr"
  talos_version       = "v1.9.2"
  kubernetes_version  = "v1.32.1"
  taloslb_revision    = "0.1.0"
  create_talos_img    = true
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

dependency "server-admin-idam_replica" {
  config_path   = "${get_terragrunt_dir()}/../server-03-admin-idam_replica"
}

#--------------------------------------------------
# Load Talos Kubernetes module
#--------------------------------------------------
terraform {
  source = "${get_terragrunt_dir()}/../../compose//cluster-admin-talos"
}