#--------------------------------------------------
# Server Admin IDAM Replica
#--------------------------------------------------
data "azurerm_image" "evovm-image" {
  name                = var.BASE_INSTALLER_IMG
  resource_group_name = var.AZ_STORAGE_RG
}

resource "azurerm_network_interface" "evo-idam-replica-nic" {
  name                = "${var.IDAM_REPLICA_SHORT_HOSTNAME}-nic"
  location            = var.rg_location
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.admin_subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.IDAM_REPLICA_PRIVATE_IP
  }
}

resource "azurerm_network_interface_security_group_association" "ngr_assoc" {
  network_interface_id      = azurerm_network_interface.evo-idam-replica-nic.id
  network_security_group_id = var.ssh_sgr
}

resource "azurerm_linux_virtual_machine" "idam_replica_server" {
  name                = var.IDAM_REPLICA_SHORT_HOSTNAME
  resource_group_name = var.rg_name
  location            = var.rg_location
  size                = var.IDAM_REPLICA_INSTANCE_SIZE
  admin_username      = var.CLOUD_USER
  network_interface_ids = [
    azurerm_network_interface.evo-idam-replica-nic.id,
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
# Ansible Configuration Management Code
#--------------------------------------------------
resource "terraform_data" "redeploy_idam_replica" {
  input = var.idam_replica_revision
}

resource "terraform_data" "idam_server_configuration" {
  depends_on = [azurerm_linux_virtual_machine.idam_replica_server]

  #Uncomment below if we want to run Triggers when VM ID changes
  #triggers_replace = [azurerm_linux_virtual_machine.idam_server]
  #Uncomment below if we want to run Triggers on Revision number increase
  lifecycle {
    replace_triggered_by = [terraform_data.redeploy_idam_replica]
  }

  provisioner "local-exec" {
    command = <<EOF
      ${var.ANSIBLE_DEBUG_FLAG ? "ANSIBLE_DEBUG=1" : ""} ANSIBLE_PIPELINING=True ansible-playbook --timeout 60 \
      /home/${var.CLOUD_USER}/EVOCLOUD/Ansible/server-admin-idam-replica.yml \
      --forks 10 \
      --inventory-file ${azurerm_linux_virtual_machine.idam_replica_server.private_ip_address}, \
      --user ${var.CLOUD_USER} \
      --private-key ${var.PRIVATE_KEY_PAIR} \
      --vault-password-file /home/${var.CLOUD_USER}/EVOCLOUD/Ansible/secret-vault/ansible-vault-pass.txt \
      --ssh-common-args '-o 'StrictHostKeyChecking=no' -o 'ControlMaster=auto' -o 'ControlPersist=120s'' \
      --extra-vars 'ansible_secret=/home/${var.CLOUD_USER}/EVOCLOUD/Ansible/secret-vault/secret-store.yml server_ip=${azurerm_linux_virtual_machine.idam_replica_server.private_ip_address} idam_server_ip=${var.idam_server_ip} idam_short_hostname=${var.IDAM_SHORT_HOSTNAME} server_short_hostname=${var.IDAM_REPLICA_SHORT_HOSTNAME} idam_replica_short_hostname=${var.IDAM_REPLICA_SHORT_HOSTNAME} domain_tld=${var.DOMAIN_TLD} server_timezone=${var.DEFAULT_TIMEZONE} cloudplatform=${var.CLOUD_PLATFORM}'
    EOF
    #Ansible logs
    environment = {
      ANSIBLE_LOG_PATH = "/home/${var.CLOUD_USER}/EVOCLOUD/Logs/server-admin-idam_replica-ansible.log"
    }
  }
}