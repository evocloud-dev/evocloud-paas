# ---------------------
# Network Security Group
# ---------------------
resource "azurerm_network_security_group" "ssh_nsg" {
  name                = "${var.AZ_PROJECT_ID}-ssh-nsg"
  location            = var.rg_location
  resource_group_name = var.rg_name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*" # Restrict to your IP in production
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "cntrl_plane_nsg" {
  name                = "${var.AZ_PROJECT_ID}-ctrlplane-nsg"
  location            = var.rg_location
  resource_group_name = var.rg_name

  security_rule {
    name                       = "Allow-k8s-api"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "6443"
    source_address_prefix      = "*" # Restrict to your IP in production
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-etcd"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "2379-2380"
    source_address_prefix      = "*" # Restrict to your IP in production
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-talos"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "50000"
    source_address_prefix      = "*" # Restrict to your IP in production
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "worker_nsg" {
  name                = "${var.AZ_PROJECT_ID}-worker-nsg"
  location            = var.rg_location
  resource_group_name = var.rg_name

  security_rule {
    name                       = "Allow-kubelet"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "10250"
    source_address_prefix      = "*" # Restrict to your IP in production
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-nodeport"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "30000-32767"
    source_address_prefix      = "*" # Restrict to your IP in production
    destination_address_prefix = "*"
  }
}