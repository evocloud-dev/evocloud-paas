#--------------------------------------------------
# Ansible Configuration Management Code
#--------------------------------------------------
resource "terraform_data" "redeploy_runner_registration" {
  input = var.runner_registration_revision
}

resource "terraform_data" "evocode_runner_server_registration" {

  #Uncomment below if we want to run Triggers on Revision number increase
  lifecycle {
    replace_triggered_by = [terraform_data.redeploy_runner_registration]
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
      "${var.ANSIBLE_DEBUG_FLAG ? "ANSIBLE_DEBUG=1" : ""} ANSIBLE_PIPELINING=True ansible-playbook --timeout 60 /home/${var.CLOUD_USER}/EVOCLOUD/Ansible/server-backend-evocode-runner-registration.yml --forks 10 --inventory-file ${var.evocode_runner_private_ip}, --user ${var.CLOUD_USER} --private-key /home/${var.CLOUD_USER}/gcp-evocloud.pem --vault-password-file /home/${var.CLOUD_USER}/EVOCLOUD/Ansible/secret-vault/ansible-vault-pass.txt --ssh-common-args '-o 'StrictHostKeyChecking=no' -o 'ControlMaster=auto' -o 'ControlPersist=120s'' --extra-vars 'ansible_secret=/home/${var.CLOUD_USER}/EVOCLOUD/Ansible/secret-vault/secret-store.yml domain_tld=${var.DOMAIN_TLD} evocode_server_ip=${var.evocode_private_ip} evocode_runner_fqdn=${var.evocode_runner_hostname_fqdn} metadata_ns_ip=${var.GCP_METADATA_NS} idam_server_ip=${var.idam_server_ip} idam_replica_ip=${var.idam_replica_ip}'",
    ]
  }
}