#--------------------------------------------------
# Deployer Server VM
#--------------------------------------------------
resource "google_compute_instance" "rdp_server" {
  name            = var.RDP_SHORT_HOSTNAME
  machine_type    = var.RDP_INSTANCE_SIZE #custom-6-20480 | custom-6-15360-ext
  description     = "RDP VM Instance"
  zone            = "${var.GCP_REGION}-a"
  hostname        = "${var.RDP_SHORT_HOSTNAME}.${var.DOMAIN_TLD}"
  enable_display  = true

  boot_disk {
    initialize_params {
      image = var.BASE_AMI_NAME
      size  = var.BASE_VOLUME_SIZE
      type  = var.RDP_BASE_VOLUME_TYPE
      labels = {
        name = "base-volume-rdp-server"
      }
    }
  }

  network_interface {
    subnetwork  = var.dmz_subnet_name

    #Assigning static public ip
    access_config {
      nat_ip = google_compute_address.rdp_server_eip.address
      network_tier = "PREMIUM" #PREMIUM | FIXED_STANDARD | STANDARD
    }
  }

  allow_stopping_for_update = true

  labels = {
    server = var.RDP_SHORT_HOSTNAME
  }

  metadata = {
    #enable-oslogin = "TRUE"
    ssh-keys       = "${var.CLOUD_USER}:${file("${var.PUBLIC_KEY_PAIR}")}"
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
# RDP Server Public IP
#--------------------------------------------------
resource "google_compute_address" "rdp_server_eip" {
  name = "rdp-server-eip"
  description = "RDP External IP"
  address_type = "EXTERNAL"
}


#--------------------------------------------------
# Ansible Configuration Management Code
#--------------------------------------------------
#replacing null_resource with terraform_data
#https://developer.hashicorp.com/terraform/language/resources/terraform-data
resource "terraform_data" "trigger_redeploy" {
  input = var.rdp_revision
}

resource "terraform_data" "rdp_server_configuration" {
  depends_on = [google_compute_instance.rdp_server]

  #Uncomment below if we want to run Triggers when VM ID changes
  #triggers_replace = [google_compute_instance.rdp_server.id]
  #or Uncomment below if we want to run Triggers on Revision number increase
  lifecycle {
    replace_triggered_by = [terraform_data.trigger_redeploy]
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
      ${var.ANSIBLE_DEBUG_FLAG ? "ANSIBLE_DEBUG=1" : ""} ANSIBLE_PIPELINING=True ansible-playbook --timeout 60 /home/${var.CLOUD_USER}/EVOCLOUD/Ansible/server-dmz-rdp.yml --forks 10 --inventory-file ${google_compute_instance.rdp_server.network_interface[0].network_ip}, --user ${var.CLOUD_USER} --private-key /etc/pki/tls/gcp-evocloud.pem --vault-password-file /home/${var.CLOUD_USER}/EVOCLOUD/Ansible/secret-vault/ansible-vault-pass.txt --ssh-common-args '-o 'StrictHostKeyChecking=no' -o 'ControlMaster=auto' -o 'ControlPersist=120s'' --extra-vars 'ansible_secret=/home/${var.CLOUD_USER}/EVOCLOUD/Ansible/secret-vault/secret-store.yml server_ip=${google_compute_instance.rdp_server.network_interface[0].network_ip} idam_server_ip=${var.idam_server_ip} idam_short_hostname=${var.IDAM_SHORT_HOSTNAME} server_short_hostname=${var.RDP_SHORT_HOSTNAME} domain_tld=${var.DOMAIN_TLD} server_timezone=${var.DEFAULT_TIMEZONE} metadata_ns_ip=${var.GCP_METADATA_NS} idam_replica_ip=${var.idam_replica_ip} cloud_platform=${var.CLOUD_PLATFORM}',
    EOF
    #Ansible logs
    environment = {
      ANSIBLE_LOG_PATH = "/home/${var.CLOUD_USER}/EVOCLOUD/Logs/server-dmz-rdp-ansible.log"
    }
  }
}