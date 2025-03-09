#--------------------------------------------------
# Input Variables
#--------------------------------------------------
inputs = {
  deployer_server_eip           = dependency.server-dmz-deployer.outputs.public_ip
  evocode_private_ip            = dependency.server-backend-evocode.outputs.private_ip
  fluxcd_repo_group             = "evosystems"
  fluxcd_git_repo               = "evocloud"
  fluxcd_repo_dir               = "Gitops/k8s-clusters/cluster-mgr0"
  fluxcd_revision               = "0.1.0"
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
# Set server-backend-evocode module dependency
#--------------------------------------------------
dependency "server-backend-evocode" {
  config_path   = "${get_terragrunt_dir()}/../server-backend-evocode"
}

#--------------------------------------------------
# Set server-backend-evocode-group module dependency
#--------------------------------------------------
dependency "server-evocode-group-project" {
  config_path   = "${get_terragrunt_dir()}/../server-backend-evocode-group"
  skip_outputs = true
}

#--------------------------------------------------
# Load Kubeapp-Flux module
#--------------------------------------------------
terraform {
  source = "${get_terragrunt_dir()}/../../compose//kubeapp-flux"
}