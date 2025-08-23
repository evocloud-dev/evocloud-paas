#--------------------------------------------------
# Ansible Configuration Management Code
#--------------------------------------------------
resource "terraform_data" "redeploy_evocode_group" {
  input = var.evocode_group_revision
}

resource "terraform_data" "evocode_group_project" {

  #Uncomment below if we want to run Triggers on Revision number increase
  lifecycle {
    replace_triggered_by = [terraform_data.redeploy_evocode_group]
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
      "${var.ANSIBLE_DEBUG_FLAG ? "ANSIBLE_DEBUG=1" : ""} ANSIBLE_PIPELINING=True ansible-playbook --timeout 60 /home/${var.CLOUD_USER}/EVOCLOUD/Ansible/server-backend-evocode-group-project.yml --forks 10 --inventory-file ${var.evocode_private_ip}, --user ${var.CLOUD_USER} --private-key /home/${var.CLOUD_USER}/gcp-evocloud.pem --vault-password-file /home/${var.CLOUD_USER}/EVOCLOUD/Ansible/secret-vault/ansible-vault-pass.txt --ssh-common-args '-o 'StrictHostKeyChecking=no' -o 'ControlMaster=auto' -o 'ControlPersist=120s'' --extra-vars 'ansible_secret=/home/${var.CLOUD_USER}/EVOCLOUD/Ansible/secret-vault/secret-store.yml evocode_server_ip=${var.evocode_private_ip}'"
    ]
  }
}