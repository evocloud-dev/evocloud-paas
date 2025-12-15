#--------------------------------------------------
# Ansible Configuration Management Code
#--------------------------------------------------
resource "terraform_data" "force_helper" {
  input = timestamp()
}

resource "terraform_data" "evoidam_deployment" {
  lifecycle {
    replace_triggered_by = [terraform_data.force_helper]
  }

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
      "cd /home/${var.CLOUD_USER}/EVOCLOUD/Terraform/gcp/deployment/server-02-admin-idam",
      "terragrunt run --all apply --non-interactive --queue-include-external",
    ]
  }
}