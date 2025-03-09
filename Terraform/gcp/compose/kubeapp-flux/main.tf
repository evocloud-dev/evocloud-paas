#--------------------------------------------------
# Ansible Configuration Management Code
#--------------------------------------------------
resource "terraform_data" "redeploy_kubeapp_flux" {
  input = var.fluxcd_revision
}

resource "terraform_data" "deploy_kubeapp_flux" {

  lifecycle {
    replace_triggered_by = [terraform_data.redeploy_kubeapp_flux]
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
      "chmod 600 /home/${var.CLOUD_USER}/gcp-evocloud.pem",
      "${var.ANSIBLE_DEBUG_FLAG ? "ANSIBLE_DEBUG=1" : ""} ANSIBLE_PIPELINING=True ansible-playbook --timeout 60 /home/${var.CLOUD_USER}/EVOCLOUD/Ansible/kubeapp-flux.yml --forks 10 --inventory-file 127.0.0.1, --user ${var.CLOUD_USER} --private-key /home/${var.CLOUD_USER}/gcp-evocloud.pem --vault-password-file /home/${var.CLOUD_USER}/EVOCLOUD/Ansible/secret-vault/ansible-vault-pass.txt --ssh-common-args '-o 'StrictHostKeyChecking=no' -o 'ControlMaster=auto' -o 'ControlPersist=120s'' --extra-vars 'ansible_secret=/home/${var.CLOUD_USER}/EVOCLOUD/Ansible/secret-vault/secret-store.yml evocode_private_ip=${var.evocode_private_ip} fluxcd_git_repo=${var.fluxcd_git_repo} fluxcd_repo_dir=${var.fluxcd_repo_dir} fluxcd_repo_group=${var.fluxcd_repo_group} cloud_user=${var.CLOUD_USER}'",
    ]
  }
}