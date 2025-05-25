#--------------------------------------------------
# Ansible Configuration Management Code
#--------------------------------------------------
resource "terraform_data" "evotalos_standalone_deployment" {
  #Connection to bastion host (DEPLOYER_Server)
  connection {
    host        = var.deployer_server_eip
    type        = "ssh"
    user        = var.CLOUD_USER
    private_key = file(var.PRIVATE_KEY_PAIR)
  }

  provisioner "remote-exec" {
    inline = [
      "export GOOGLE_APPLICATION_CREDENTIALS='/home/${var.CLOUD_USER}/EVOCLOUD/Keys/${var.GCP_JSON_CREDS}'",
      "gcloud auth activate-service-account --key-file /home/${var.CLOUD_USER}/EVOCLOUD/Keys/${var.GCP_JSON_CREDS}",
      "cd /home/${var.CLOUD_USER}/EVOCLOUD/Terraform/gcp/deployment/cluster-talos-standalone",
      "terragrunt run-all apply --terragrunt-non-interactive --terragrunt-include-external-dependencies -auto-approve",
    ]
  }
}