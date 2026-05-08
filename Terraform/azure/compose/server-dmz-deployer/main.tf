#--------------------------------------------------
# Server DMZ Main
#--------------------------------------------------
data "azurerm_shared_image" "rocky-linux" {
  name                = var.BASE_INSTALLER_IMG
  resource_group_name = var.AZ_STORAGE_RG
}

resource "azurerm_network_interface" "evo-master-nic" {
  name                = "${var.DEPLOYER_SHORT_HOSTNAME}-nic"
  location            = var.rg_location
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.dmz_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
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

  source_image_id = data.azurerm_shared_image.rocky-linux.id
  admin_ssh_key {
    username   = var.CLOUD_USER
    public_key = "${file("${var.PUBLIC_KEY_PAIR}")}"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}