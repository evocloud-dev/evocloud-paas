#--------------------------------------------------
# Server SSH Key
#--------------------------------------------------

#Uncomment the code snippet below if you uncomment enable-oslogin
#
data "google_client_openid_userinfo" "current" {
}

#resource "google_os_login_ssh_public_key" "cache" {
#  user =  data.google_client_openid_userinfo.me.email
#  key = file(var.PUBLIC_KEY_PAIR)
#}

#--------------------------------------------------
# Deployer Server VM
#--------------------------------------------------
resource "google_compute_instance" "deployer_server" {
  name         = var.DEPLOYER_SHORT_HOSTNAME
  machine_type = var.DEPLOYER_INSTANCE_SIZE #custom-6-20480 | custom-6-15360-ext
  description  = "DEPLOYER VM Instance"
  zone         = "${var.GCP_REGION}-a"
  hostname     = "${var.DEPLOYER_SHORT_HOSTNAME}.${var.DOMAIN_TLD}"

  boot_disk {
    initialize_params {
      image = var.BASE_INSTALLER_IMG
      size  = var.BASE_VOLUME_SIZE
      type  = var.DEPLOYER_BASE_VOLUME_TYPE
      labels = {
        name = "base-volume-deployer"
      }
    }
  }

  network_interface {
    subnetwork  = var.dmz_subnet_name
    network_ip  = var.DEPLOYER_PRIVATE_IP

    #Assigning static public ip
    access_config {
      nat_ip = google_compute_address.deployer_server_eip.address
      network_tier = "PREMIUM" #PREMIUM | FIXED_STANDARD | STANDARD
    }
  }

  allow_stopping_for_update = true

  labels = {
    server = var.DEPLOYER_SHORT_HOSTNAME
  }

  metadata = {
    #enable-oslogin = "TRUE"
    ssh-keys       = "${var.CLOUD_USER}:${file("${var.PUBLIC_KEY_PAIR}")}"
  }

  metadata_startup_script = "/usr/bin/date"

  #For selecting Spot Instances - Remove this snippet in production
  scheduling {
    preemptible = var.use_spot ? true : false
    automatic_restart = false
    provisioning_model = var.use_spot ? "SPOT" : "STANDARD"
    instance_termination_action = var.use_spot ? "STOP" : "" #DELETE | STOP
  }

  #Assigning service account for node to be able to update aliased IP in fail over scenario
  service_account {
    email  = data.google_client_openid_userinfo.current.email  # Inherit the running SA
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}

#--------------------------------------------------
# Deployer Server Public IP
#--------------------------------------------------
resource "google_compute_address" "deployer_server_eip" {
  name = "deployer-server-eip"
  description = "DEPLOYER External IP"
  address_type = "EXTERNAL"
}

#--------------------------------------------------
# Staging Deployment Artifacts
#--------------------------------------------------
resource "terraform_data" "staging_automation_code" {
  depends_on = [google_compute_instance.deployer_server]

  connection {
    host        = google_compute_address.deployer_server_eip.address
    type        = "ssh"
    user        = var.CLOUD_USER
    private_key = file(var.PRIVATE_KEY_PAIR)
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/${var.CLOUD_USER}/EVOCLOUD"
    ]
  }

  provisioner "file" {
    source        = "/etc/ansible/ansible.cfg"
    destination   = "/tmp/ansible.cfg"
  }

  provisioner "file" {
    source        = var.PRIVATE_KEY_PAIR
    destination   = "/home/${var.CLOUD_USER}/gcp-evocloud.pem"
  }

  provisioner "file" {
    source        = var.PUBLIC_KEY_PAIR
    destination   = "/home/${var.CLOUD_USER}/gcp-evocloud.pub"
  }

  provisioner "file" {
    source        = "${var.AUTOMATION_FOLDER}/evocloud.tar.gz"
    destination   = "/home/${var.CLOUD_USER}/evocloud.tar.gz"
  }

  provisioner "file" {
    source        = "${var.AUTOMATION_FOLDER}/Keys/${var.GCP_JSON_CREDS}"
    destination   = "/home/${var.CLOUD_USER}/${var.GCP_JSON_CREDS}"
  }

  provisioner "file" {
    source        = "${var.AUTOMATION_FOLDER}/Ansible/secret-vault/ansible-vault-pass.txt"
    destination   = "/home/${var.CLOUD_USER}/ansible-vault-pass.txt"
  }

  provisioner "file" {
    source        = "${var.AUTOMATION_FOLDER}/Ansible/secret-vault/secret-store.yml"
    destination   = "/home/${var.CLOUD_USER}/secret-store.yml"
  }

  provisioner "file" {
    source        = "${var.AUTOMATION_FOLDER}/Terraform/gcp/deployment/root.hcl"
    destination   = "/home/${var.CLOUD_USER}/root.hcl"
  }

  provisioner "remote-exec" {
    inline = [
      # Unpacks tarball and cleans up
      "tar -xzf /home/${var.CLOUD_USER}/evocloud.tar.gz --strip-components=1 -C /home/${var.CLOUD_USER}/EVOCLOUD",
      "rm -f /home/${var.CLOUD_USER}/evocloud.tar.gz",

      # Moves public and private keys to /etc/pki/tls folder
      # and gives proper ownership and permissions
      "sudo mv /home/${var.CLOUD_USER}/gcp-evocloud.pem /etc/pki/tls",
      "sudo mv /home/${var.CLOUD_USER}/gcp-evocloud.pub /etc/pki/tls",
      "sudo chmod 0600 /etc/pki/tls/gcp-evocloud.pem",
      "sudo chmod 0644 /etc/pki/tls/gcp-evocloud.pub",
      "sudo chown ${var.CLOUD_USER}:${var.CLOUD_USER} /etc/pki/tls/gcp-evocloud.pem",
      "sudo chown ${var.CLOUD_USER}:${var.CLOUD_USER} /etc/pki/tls/gcp-evocloud.pub",

      # Moves Ansible secret-store and vault-pass to Ansible/secret-vault folder
      "mv /home/${var.CLOUD_USER}/secret-store.yml /home/${var.CLOUD_USER}/EVOCLOUD/Ansible/secret-vault/secret-store.yml",
      "mv /home/${var.CLOUD_USER}/ansible-vault-pass.txt /home/${var.CLOUD_USER}/EVOCLOUD/Ansible/secret-vault/ansible-vault-pass.txt",

      # Moves GCP Key to Keys folder
      "mv /home/${var.CLOUD_USER}/${var.GCP_JSON_CREDS} /home/${var.CLOUD_USER}/EVOCLOUD/Keys/${var.GCP_JSON_CREDS}",

      # Move root.hcl into deployment folder
      "mv /home/${var.CLOUD_USER}/root.hcl /home/${var.CLOUD_USER}/EVOCLOUD/Terraform/gcp/deployment/root.hcl",

      "sudo yum update -y",
      "hostnamectl status"
    ]
  }

}

#--------------------------------------------------
# Ansible Configuration Management Code
#--------------------------------------------------
resource "terraform_data" "redeploy_deployer" {
  input = var.deployer_revision
}

resource "terraform_data" "deployer_server_configuration" {
  depends_on = [
    google_compute_instance.deployer_server,
    terraform_data.staging_automation_code
  ]

  #Uncomment below if we want to run Triggers when VM ID changes
  #triggers_replace = [google_compute_instance.deployer_server]
  #Uncomment below if we want to run Triggers on Revision number increase
  lifecycle {
    replace_triggered_by = [terraform_data.redeploy_deployer]
  }

  provisioner "local-exec" {
    command = <<EOF
      ${var.ANSIBLE_DEBUG_FLAG ? "ANSIBLE_DEBUG=1" : ""} ANSIBLE_PIPELINING=True ansible-playbook --timeout 60 ${var.AUTOMATION_FOLDER}/Ansible/server-dmz-deployer.yml --forks 10 --inventory-file ${google_compute_address.deployer_server_eip.address}, --user ${var.CLOUD_USER} --private-key ${var.PRIVATE_KEY_PAIR} --ssh-common-args "-o 'StrictHostKeyChecking=no'"
    EOF
    #Ansible logs
    environment = {
      ANSIBLE_LOG_PATH = "/home/${var.CLOUD_USER}/EVOCLOUD/Logs/deployer_server-ansible.log"
    }
  }
}