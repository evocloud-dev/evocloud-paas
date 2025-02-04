#--------------------------------------------------
# Server SSH Key
#--------------------------------------------------

#Uncomment the code snippet below if you uncomment enable-oslogin
#
#data "google_client_openid_userinfo" "me" {
#}

#resource "google_os_login_ssh_public_key" "cache" {
#  user =  data.google_client_openid_userinfo.me.email
#  key = file(var.PUBLIC_KEY_PAIR)
#}

#--------------------------------------------------
# IDAM Replica Server VM
#--------------------------------------------------
resource "google_compute_instance" "idam_replica_server" {
  name         = var.IDAM_REPLICA_SHORT_HOSTNAME
  machine_type = var.IDAM_REPLICA_INSTANCE_SIZE #custom-6-20480 | custom-6-15360-ext
  description  = "IDAM Replica VM Instance"
  zone         = "${var.GCP_REGION}-b"
  hostname     = "${var.IDAM_REPLICA_SHORT_HOSTNAME}.${var.DOMAIN_TLD}"

  boot_disk {
    initialize_params {
      image = var.BASE_AMI_NAME
      size  = var.BASE_VOLUME_SIZE
      type  = var.IDAM_REPLICA_BASE_VOLUME_TYPE
      labels = {
        name = "base-volume-idam-replica"
      }
    }
  }

  network_interface {
    subnetwork  = var.admin_subnet_name
    network_ip  = var.IDAM_REPLICA_PRIVATE_IP
  }

  allow_stopping_for_update = true

  labels = {
    server = var.IDAM_REPLICA_SHORT_HOSTNAME
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
# Ansible Inventory for IDAM Replica Server VM
#--------------------------------------------------
resource "local_file" "idam_replica_ansible_inventory" {
  depends_on  = [google_compute_instance.idam_replica_server]

  filename    = "${var.AUTOMATION_FOLDER}/gcp_host_idam_replica_server.ini"
  directory_permission = "0775"
  file_permission      = "0775"
  content     = <<-EOF
    [idam_server_replica]
    ansible_ssh_host=${google_compute_instance.idam_replica_server.network_interface[0].network_ip}
  EOF
}

#--------------------------------------------------
# Staging Ansible Inventory File
#--------------------------------------------------
resource "null_resource" "staging_ansible_inventory" {
  depends_on = [local_file.idam_replica_ansible_inventory]

  connection {
    host        = var.deployer_server_eip
    type        = "ssh"
    user        = var.CLOUD_USER
    private_key = file(var.PRIVATE_KEY_PAIR)
  }

  provisioner "file" {
    source        = "${var.AUTOMATION_FOLDER}/gcp_host_idam_replica_server.ini"
    destination   = "/home/${var.CLOUD_USER}/gcp_host_idam_replica_server.ini"
  }
}

#--------------------------------------------------
# Ansible Configuration Management Code
#--------------------------------------------------
resource "terraform_data" "redeploy_idam_replica" {
  input = var.idam_replica_revision
}

resource "terraform_data" "idam_replica_server_configuration" {
  depends_on = [google_compute_instance.idam_replica_server]

  #Uncomment below if we want to run Triggers when VM ID changes
  triggers_replace = [google_compute_instance.idam_replica_server]
  #Uncomment below if we want to run Triggers on Revision number increase
  lifecycle {
    replace_triggered_by = [terraform_data.redeploy_idam_replica]
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
      "${var.ANSIBLE_DEBUG_FLAG ? "ANSIBLE_DEBUG=1" : ""} ANSIBLE_PIPELINING=True ansible-playbook --timeout 60 /home/${var.CLOUD_USER}/EVOCLOUD/Ansible/server-admin-idam-replica.yml --forks 10 --inventory-file ${google_compute_instance.idam_replica_server.network_interface[0].network_ip}, --user ${var.CLOUD_USER} --private-key /home/${var.CLOUD_USER}/gcp-evocloud.pem --vault-password-file /home/${var.CLOUD_USER}/EVOCLOUD/Ansible/secret-vault/ansible-vault-pass.txt --ssh-common-args '-o 'StrictHostKeyChecking=no' -o 'ControlMaster=auto' -o 'ControlPersist=120s'' --extra-vars 'ansible_secret=/home/${var.CLOUD_USER}/EVOCLOUD/Ansible/secret-vault/secret-store.yml server_ip=${google_compute_instance.idam_replica_server.network_interface[0].network_ip} idam_server_ip=${var.idam_server_ip} idam_replica_ip=${google_compute_instance.idam_replica_server.network_interface[0].network_ip} idam_short_hostname=${var.IDAM_SHORT_HOSTNAME} server_short_hostname=${var.IDAM_REPLICA_SHORT_HOSTNAME} idam_replica_short_hostname=${var.IDAM_REPLICA_SHORT_HOSTNAME} domain_tld=${var.DOMAIN_TLD} server_timezone=${var.DEFAULT_TIMEZONE} metadata_ns_ip=${var.GCP_METADATA_NS} cloud_platform=${var.CLOUD_PLATFORM}'",
    ]
  }
}