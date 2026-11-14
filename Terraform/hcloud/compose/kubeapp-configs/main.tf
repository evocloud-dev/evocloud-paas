#--------------------------------------------------
# Kubeapp Configurations
# Ansible Configuration Management Code
#--------------------------------------------------

data "hcloud_load_balancer" "gtw_lb" {
  name = var.TALOS_LB_NAME
}

#replacing null_resource with terraform_data
#https://developer.hashicorp.com/terraform/language/resources/terraform-data
resource "terraform_data" "redeploy_kubeapps_configuration" {
  input = var.kubeapp_configs_revision
}

resource "terraform_data" "evok8s_kubeapps_configuration" {
  #Uncomment below if we want to run Triggers when VM ID changes
  #triggers_replace = [hcloud_server.rdp_server.id]
  #or Uncomment below if we want to run Triggers on Revision number increase
  lifecycle {
    replace_triggered_by = [terraform_data.redeploy_kubeapps_configuration]
  }

  provisioner "local-exec" {
    command = <<EOF
      ${var.ANSIBLE_DEBUG_FLAG ? "ANSIBLE_DEBUG=1" : ""} ANSIBLE_PIPELINING=True ansible-playbook --timeout 60 \
      /home/${var.CLOUD_USER}/EVOCLOUD/Ansible/evok8s-kubeapp-configs.yml \
      --forks 10 \
      --inventory-file 127.0.0.1, \
      --user ${var.CLOUD_USER} \
      --private-key ${var.PRIVATE_KEY_PAIR} \
      --vault-password-file /home/${var.CLOUD_USER}/EVOCLOUD/Ansible/secret-vault/ansible-vault-pass.txt \
      --ssh-common-args "-o 'StrictHostKeyChecking=no' -o 'ControlMaster=auto' -o 'ControlPersist=120s'" \
      --extra-vars "ansible_secret=/home/${var.CLOUD_USER}/EVOCLOUD/Ansible/secret-vault/secret-store.yml idam_server_ip=${var.idam_server_ip} idam_short_hostname=${var.IDAM_SHORT_HOSTNAME} domain_tld=${var.DOMAIN_TLD} idam_replica_ip=${var.idam_replica_ip} kube_cluster_name=${var.cluster_name} gtw_lb_ip=${data.hcloud_load_balancer.gtw_lb.ipv4}"
    EOF
    #Ansible logs
    environment = {
      ANSIBLE_LOG_PATH = "/${var.CLOUD_USER}/EVOCLOUD/Logs/evok8s-kubeapp-configs-ansible.log"
    }
  }
}