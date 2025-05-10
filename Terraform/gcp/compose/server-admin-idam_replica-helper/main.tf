#--------------------------------------------------
# Ansible Configuration Management Code
#--------------------------------------------------
resource "terraform_data" "evoidam-replica_deployment" {
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
      "cd /home/${var.CLOUD_USER}/EVOCLOUD/Terraform/gcp/deployment/server-03-admin-idam_replica",
      "terragrunt apply --auto-approve",
    ]
  }
}