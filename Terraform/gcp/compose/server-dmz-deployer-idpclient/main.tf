#--------------------------------------------------
# Ansible Configuration Management Code
#--------------------------------------------------
resource "terraform_data" "redeploy_ipaclient" {
  input = var.ipaclient_revision
}

resource "terraform_data" "deployer_server_idam_configuration" {

  #Uncomment below if we want to run Triggers on Revision number increase
  lifecycle {
    replace_triggered_by = [terraform_data.redeploy_ipaclient]
  }

  #Connection to bastion host (DEPLOYER_Server)
  connection {
    host        = var.deployer_server_eip
    type        = "ssh"
    user        = var.CLOUD_USER
    private_key = file(var.PRIVATE_KEY_PAIR)
  }

  provisioner "local-exec" {
    command = <<EOF
      ${var.ANSIBLE_DEBUG_FLAG ? "ANSIBLE_DEBUG=1" : ""} ANSIBLE_PIPELINING=True ansible-playbook --timeout 60 /home/${var.CLOUD_USER}/EVOCLOUD/Ansible/server-dmz-deployer-idpclient.yml --forks 10 --inventory-file ${var.deployer_private_ip}, --user ${var.CLOUD_USER} --private-key /etc/pki/tls/gcp-evocloud.pem --vault-password-file /home/${var.CLOUD_USER}/EVOCLOUD/Ansible/secret-vault/ansible-vault-pass.txt --ssh-common-args '-o 'StrictHostKeyChecking=no' -o 'ControlMaster=auto' -o 'ControlPersist=120s'' --extra-vars 'ansible_secret=/home/${var.CLOUD_USER}/EVOCLOUD/Ansible/secret-vault/secret-store.yml server_ip=${var.deployer_private_ip} idam_server_ip=${var.idam_server_ip} idam_short_hostname=${var.IDAM_SHORT_HOSTNAME} server_short_hostname=${var.DEPLOYER_SHORT_HOSTNAME} domain_tld=${var.DOMAIN_TLD} server_timezone=${var.DEFAULT_TIMEZONE} metadata_ns_ip=${var.GCP_METADATA_NS} idam_replica_ip=${var.idam_replica_ip}'
    EOF
    #Ansible logs
    environment = {
      ANSIBLE_LOG_PATH = "${var.AUTOMATION_FOLDER}/Logs/deployer_server_idpclient-ansible.log"
    }
  }
}