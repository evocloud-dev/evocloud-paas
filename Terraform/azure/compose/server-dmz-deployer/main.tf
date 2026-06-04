#--------------------------------------------------
# Server DMZ Main
#--------------------------------------------------
data "azurerm_image" "evovm-image" {
  name                = var.BASE_INSTALLER_IMG
  resource_group_name = var.AZ_STORAGE_RG
}

resource "azurerm_public_ip" "evo_master_public_ip" {
  name                = "${var.DEPLOYER_SHORT_HOSTNAME}-public-ip"
  location            = var.rg_location
  resource_group_name = var.rg_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "evo-master-nic" {
  name                = "${var.DEPLOYER_SHORT_HOSTNAME}-nic"
  location            = var.rg_location
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.dmz_subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.DEPLOYER_PRIVATE_IP
    public_ip_address_id          = azurerm_public_ip.evo_master_public_ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "nsg_assoc" {
  network_interface_id      = azurerm_network_interface.evo-master-nic.id
  network_security_group_id = var.ssh_sgr
}

resource "azurerm_linux_virtual_machine" "evo-master" {
  name                = var.DEPLOYER_SHORT_HOSTNAME
  resource_group_name = var.rg_name
  location            = var.rg_location
  size                = var.DEPLOYER_INSTANCE_SIZE
  admin_username      = var.CLOUD_USER
  network_interface_ids = [
    azurerm_network_interface.evo-master-nic.id,
  ]

  source_image_id = data.azurerm_image.evovm-image.id

  admin_ssh_key {
    username   = var.CLOUD_USER
    public_key = "${file("${var.PUBLIC_KEY_PAIR}")}"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  #source_image_id = "/subscriptions/ad0bf289-b1c8-43d4-b325-997780dc89d9/resourceGroups/STORAGE-RG/providers/Microsoft.Compute/images/evovm-os-8-10"
}

#--------------------------------------------------
# Staging Deployment Artifacts
#--------------------------------------------------
resource "terraform_data" "staging_automation_code" {
  depends_on = [azurerm_linux_virtual_machine.evo-master]

  connection {
    host        = azurerm_public_ip.evo_master_public_ip.ip_address
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
    destination   = "/home/${var.CLOUD_USER}/az-evonode.pem"
  }

  provisioner "file" {
    source        = var.PUBLIC_KEY_PAIR
    destination   = "/home/${var.CLOUD_USER}/az-evonode.pub"
  }

  provisioner "file" {
    source        = "${var.AUTOMATION_FOLDER}/evocloud.tar.gz"
    destination   = "/home/${var.CLOUD_USER}/evocloud.tar.gz"
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
    source        = "${var.AUTOMATION_FOLDER}/Terraform/azure/deployment/root.hcl"
    destination   = "/home/${var.CLOUD_USER}/root.hcl"
  }

  provisioner "remote-exec" {
    inline = [
      # Unpacks tarball and cleans up
      "tar -xzf /home/${var.CLOUD_USER}/evocloud.tar.gz --strip-components=1 -C /home/${var.CLOUD_USER}/EVOCLOUD",
      "rm -f /home/${var.CLOUD_USER}/evocloud.tar.gz",

      # Moves Nodes key pairs to /etc/pki/tls folder
      # and gives proper ownership and permissions
      "sudo mv /home/${var.CLOUD_USER}/az-evonode.pem /etc/pki/tls",
      "sudo mv /home/${var.CLOUD_USER}/az-evonode.pub /etc/pki/tls",
      "sudo chmod 0600 /etc/pki/tls/az-evonode.pem",
      "sudo chmod 0644 /etc/pki/tls/az-evonode.pub",
      "sudo chown ${var.CLOUD_USER}:${var.CLOUD_USER} /etc/pki/tls/az-evonode.pem",
      "sudo chown ${var.CLOUD_USER}:${var.CLOUD_USER} /etc/pki/tls/az-evonode.pub",

      # Moves Ansible secret-store and vault-pass to Ansible/secret-vault folder
      "mv /home/${var.CLOUD_USER}/secret-store.yml /home/${var.CLOUD_USER}/EVOCLOUD/Ansible/secret-vault/secret-store.yml",
      "mv /home/${var.CLOUD_USER}/ansible-vault-pass.txt /home/${var.CLOUD_USER}/EVOCLOUD/Ansible/secret-vault/ansible-vault-pass.txt",

      # Moves root.hcl into deployment folder
      "mv /home/${var.CLOUD_USER}/root.hcl /home/${var.CLOUD_USER}/EVOCLOUD/Terraform/azure/deployment/root.hcl",

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
    azurerm_linux_virtual_machine.evo-master,
    terraform_data.staging_automation_code
  ]

  lifecycle {
    replace_triggered_by = [terraform_data.redeploy_deployer]
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command = <<EOF
      ${var.ANSIBLE_DEBUG_FLAG ? "ANSIBLE_DEBUG=1" : ""} ANSIBLE_PIPELINING=True ansible-playbook --timeout 60 \
      ${var.AUTOMATION_FOLDER}/Ansible/server-dmz-deployer.yml \
      --forks 10 \
      --inventory-file \
      ${azurerm_public_ip.evo_master_public_ip.ip_address}, \
      --user ${var.CLOUD_USER} \
      --private-key ${var.PRIVATE_KEY_PAIR} \
      --ssh-common-args "-o 'StrictHostKeyChecking=no'"
    EOF
    #Ansible logs
    environment = {
      ANSIBLE_LOG_PATH = "/home/${var.CLOUD_USER}/EVOCLOUD/Logs/deployer_server-ansible.log"
    }
  }
}