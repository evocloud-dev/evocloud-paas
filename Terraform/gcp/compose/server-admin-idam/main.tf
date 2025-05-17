#--------------------------------------------------
# IDAM Server VM
#--------------------------------------------------
resource "google_compute_instance" "idam_server" {
  name         = var.IDAM_SHORT_HOSTNAME
  machine_type = var.IDAM_INSTANCE_SIZE #custom-6-20480 | custom-6-15360-ext
  description  = "IDAM VM Instance"
  zone         = "${var.GCP_REGION}-a"
  hostname     = "${var.IDAM_SHORT_HOSTNAME}.${var.DOMAIN_TLD}"

  boot_disk {
    initialize_params {
      image = var.BASE_IPASERVER_IMG
      size  = var.BASE_VOLUME_SIZE
      type  = var.IDAM_BASE_VOLUME_TYPE
      labels = {
        name = "base-volume-idam"
      }
    }
  }

  network_interface {
    subnetwork  = var.admin_subnet_name
    network_ip  = var.IDAM_PRIVATE_IP
  }

  allow_stopping_for_update = true

  labels = {
    server = var.IDAM_SHORT_HOSTNAME
  }

  metadata = {
    #enable-oslogin = "TRUE"
    ssh-keys       = "${var.CLOUD_USER}:${file("/etc/pki/tls/gcp-evocloud.pub")}"
  }

  metadata_startup_script = "/usr/bin/date"

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
resource "terraform_data" "redeploy_idam" {
  input = var.idam_revision
}

resource "terraform_data" "idam_server_configuration" {
  depends_on = [google_compute_instance.idam_server]

  #Uncomment below if we want to run Triggers when VM ID changes
  #triggers_replace = [google_compute_instance.idam_server]
  #Uncomment below if we want to run Triggers on Revision number increase
  lifecycle {
    replace_triggered_by = [terraform_data.redeploy_idam]
  }

  provisioner "local-exec" {
    command = <<EOF
      ${var.ANSIBLE_DEBUG_FLAG ? "ANSIBLE_DEBUG=1" : ""} ANSIBLE_PIPELINING=True ansible-playbook --timeout 60 /home/${var.CLOUD_USER}/EVOCLOUD/Ansible/server-admin-idam.yml --forks 10 --inventory-file ${google_compute_instance.idam_server.network_interface[0].network_ip}, --user ${var.CLOUD_USER} --private-key /etc/pki/tls/gcp-evocloud.pem --vault-password-file /etc/pki/tls/EVOCLOUD/Ansible/secret-vault/ansible-vault-pass.txt --ssh-common-args '-o 'StrictHostKeyChecking=no' -o 'ControlMaster=auto' -o 'ControlPersist=120s'' --extra-vars 'ansible_secret=/home/${var.CLOUD_USER}/EVOCLOUD/Ansible/secret-vault/secret-store.yml server_ip=${google_compute_instance.idam_server.network_interface[0].network_ip} idam_short_hostname=${var.IDAM_SHORT_HOSTNAME} domain_tld=${var.DOMAIN_TLD} server_timezone=${var.DEFAULT_TIMEZONE}'
    EOF
    #Ansible logs
    environment = {
      ANSIBLE_LOG_PATH = "${var.AUTOMATION_FOLDER}/Logs/server-admin-idam-ansible.log"
    }
  }
}