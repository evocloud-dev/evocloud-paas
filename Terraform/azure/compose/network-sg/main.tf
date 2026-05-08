# ---------------------
# Network Security Group
# ---------------------
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.AZ_PROJECT_ID}-nsg"
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