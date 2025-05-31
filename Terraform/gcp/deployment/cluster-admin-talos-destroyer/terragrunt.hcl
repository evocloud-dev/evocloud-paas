#--------------------------------------------------
# Input Variables
#--------------------------------------------------
inputs = {
  deployer_server_eip = dependency.server-dmz-deployer.outputs.public_ip
}

#--------------------------------------------------
# Include root terragrunt.hcl file
#--------------------------------------------------
include "root" {
  path = find_in_parent_folders("root.hcl")
}

#--------------------------------------------------
# Load cluster-admin-talos-destroyer module
#--------------------------------------------------
terraform {
  source = "${get_terragrunt_dir()}/../../compose//cluster-admin-talos-destroy"
}