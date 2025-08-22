#--------------------------------------------------
# Terragrunt Destroy Code
#--------------------------------------------------
resource "terraform_data" "force_helper" {
  input = timestamp()
}

resource "terraform_data" "evotalos_standalone_destroy" {
  lifecycle {
    replace_triggered_by = [terraform_data.force_helper]
  }

  #Connection to bastion host (DEPLOYER_Server)
  connection {
    host        = var.deployer_server_eip
    type        = "ssh"
    user        = var.CLOUD_USER
    private_key = file(var.PRIVATE_NODE_KEY_PAIR)
  }

  provisioner "remote-exec" {
    inline = [
      "cd /home/${var.CLOUD_USER}/EVOCLOUD/Terraform/oci/deployment/cluster-talos-standalone",
      "terragrunt destroy --non-interactive -auto-approve",
    ]
  }
}