#--------------------------------------------------
# Server SSH Key
#--------------------------------------------------

#------------------------------------------------------
# EvoHarbor Enterprise OCI Registry
#------------------------------------------------------
resource "google_compute_instance" "evoharbor_server" {
  name         = var.EVOHARBOR_SHORT_HOSTNAME
  machine_type = var.EVOHARBOR_INSTANCE_SIZE #custom-6-20480 | custom-6-15360-ext
  description  = "EvoHarbor VM Instance"
  zone         = "${var.GCP_REGION}-a"
  hostname     = "${var.EVOHARBOR_SHORT_HOSTNAME}.${var.DOMAIN_TLD}"

  boot_disk {
    initialize_params {
      image = var.BASE_AMI_NAME
      size  = var.BASE_VOLUME_SIZE
      type  = var.EVOHARBOR_BASE_VOLUME_TYPE
      labels = {
        name = "base-volume-evoharbor-server"
      }
    }
  }

  network_interface {
    subnetwork  = var.backend_subnet_name
  }

  allow_stopping_for_update = true

  labels = {
    server = var.EVOHARBOR_SHORT_HOSTNAME
  }

  metadata = {
    #enable-oslogin = "TRUE"
    ssh-keys       = "${var.CLOUD_USER}:${file("/home/${var.CLOUD_USER}/gcp-evocloud.pub")}"
  }

  #For selecting Spot Instances - Remove this snippet in production
  scheduling {
    preemptible = true
    automatic_restart = false
    provisioning_model = "SPOT" #SPOT | STANDARD
    instance_termination_action = "STOP" #DELETE | STOP
  }
}

#--------------------------------------------------
# Ansible Configuration Management Code
#--------------------------------------------------
resource "terraform_data" "trigger_redeploy" {
    input = var.evoharbor_revision
}

resource "terraform_data" "evoharbor_server_configuration" {
  depends_on = [google_compute_instance.evoharbor_server]

  #Uncomment below if we want to run Triggers when VM ID changes
  #triggers_replace = [google_compute_instance.evoharbor_server.id]
  #or Uncomment below if we want to run Triggers on Revision number increase
  lifecycle {
    replace_triggered_by = [terraform_data.trigger_redeploy]
  }

  #Connection to bastion host (DEPLOYER_Server)
  connection {
    host = var.deployer_server_eip
    type = "ssh"
    user = var.CLOUD_USER
    private_key = file(var.PRIVATE_KEY_PAIR)
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 600 /home/${var.CLOUD_USER}/gcp-evocloud.pem",
      "${var.ANSIBLE_DEBUG_FLAG ? "ANSIBLE_DEBUG=1" : ""} ANSIBLE_PIPELINING=True ansible-playbook /home/${var.CLOUD_USER}/EVOCLOUD/Ansible/server-backend-evoharbor.yml --forks 10 --inventory-file ${google_compute_instance.evoharbor_server.network_interface[0].network_ip}, --user ${var.CLOUD_USER} --private-key /home/${var.CLOUD_USER}/gcp-evocloud.pem --vault-password-file /home/${var.CLOUD_USER}/EVOCLOUD/Ansible/secret-vault/ansible-vault-pass.txt --ssh-common-args '-o 'StrictHostKeyChecking=no'' --extra-vars 'ansible_secret=/home/${var.CLOUD_USER}/EVOCLOUD/Ansible/secret-vault/secret-store.yml server_ip=${google_compute_instance.evoharbor_server.network_interface[0].network_ip} idam_server_ip=${var.idam_server_ip} idam_short_hostname=${var.IDAM_SHORT_HOSTNAME} server_short_hostname=${var.EVOHARBOR_SHORT_HOSTNAME} domain_tld=${var.DOMAIN_TLD} server_timezone=${var.DEFAULT_TIMEZONE} cloud_user=${var.CLOUD_USER} metadata_ns_ip=${var.GCP_METADATA_NS} idam_replica_ip=${var.idam_replica_ip}'",
    ]
  }
}